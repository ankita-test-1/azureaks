# Private DNS Zone for the AKS API server — the private-link piece that lets
# anything inside the VNet resolve the cluster's private FQDN.
resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = var.resource_group_name
}

resource "time_sleep" "rbac_propagation" {
  depends_on = [
    azurerm_role_assignment.aks_private_dns,
    azurerm_role_assignmen.aks_network,
  ]
  create_duration = "90s"
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "${var.cluster_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = "1.34"

  # --- Private cluster ---
  private_cluster_enabled             = true
  private_dns_zone_id                 = azurerm_private_dns_zone.aks.id
  private_cluster_public_fqdn_enabled = false

  # Azure's equivalent of IRSA — not consumed by anything yet, but ArgoCD
  # or an app will likely want it soon.
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # System pool: critical add-ons only, nothing user-scheduled here.
  default_node_pool {
    name                          = "system"
    vm_size                       = var.system_vm_size
    vnet_subnet_id                = var.node_subnet_id
    os_disk_size_gb                = var.disk_size
    only_critical_addons_enabled  = true
    auto_scaling_enabled          = true
    min_count                     = 2
    max_count                     = 3
    zones                         = var.zones
  }

  network_profile {
    network_plugin      = "none"
    pod_cidr = var.pod_cidr
    service_cidr = var.service_cidr
    dns_service_ip = var.dns_service_ip
    outbound_type = "userAssignedNATGateway"
    load_balancer_sku = "standard"
  }

  depends_on= [
    time_sleep.rbac_propagation,
  ]

  lifecycle {
    ignore_changes = [default_node_pool[0].node_count]
  }
}

locals {
  node_priority = var.capacity_type == "SPOT" ? "Spot" : "Regular"
}

# Direct equivalent of the old aws_eks_node_group.
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = var.node_group_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.vm_size
  vnet_subnet_id        = var.node_subnet_id
  os_disk_size_gb       = var.disk_size
  mode                  = "User"
  zones                 = var.zones

  auto_scaling_enabled = true
  node_count           = var.desired_size
  min_count            = var.min_size
  max_count            = var.max_size

  priority        = local.node_priority
  eviction_policy = local.node_priority == "Spot" ? "Delete" : null
  spot_max_price  = local.node_priority == "Spot" ? -1 : null

  lifecycle {
    ignore_changes = [node_count]
  }
}

# --- Role assignments the cluster needs ---

resource "azurerm_user_assigned_identity" "aks" {
  name = "${var.cluster_name}-identity"
  location = var.location
  resource_group_name = var.resource_group_name
}

# Lets the cluster identity write the API server's record into our zone.
resource "azurerm_role_assignment" "aks_private_dns" {
  scope                = azurerm_private_dns_zone.aks.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Lets the cluster identity manage NICs/LB rules in the subnet we pre-wired
# (NSG, NAT Gateway) rather than one AKS created for itself.
resource "azurerm_role_assignment" "aks_network" {
  scope                = var.node_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Lets nodes actually pull images — equivalent of the old ecr_policy attachment.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
