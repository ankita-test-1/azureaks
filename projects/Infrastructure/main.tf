resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source = "./modules/vnet"

  vnet_name             = var.vnet_name
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  address_space         = var.address_space
  node_subnet_cidr      = var.node_subnet_cidr
  zones                 = var.zones
}

module "acr" {
  source = "./modules/acr"

  acr_name             = var.acr_name
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  sku                  = var.acr_sku
  repositories         = var.repositories
}

module "aks" {
  source = "./modules/aks"

  cluster_name        = var.cluster_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  vnet_id             = module.vnet.vnet_id
  node_subnet_id      = module.vnet.node_subnet_id
  acr_id              = module.acr.acr_id

  system_vm_size  = var.system_vm_size
  vm_size         = var.vm_size
  node_group_name = var.node_group_name
  capacity_type   = var.capacity_type
  pod_cidr = var.pod_cidr
  service_cidr = var.service_cidr
  dns_service_ip = var.dns_service_ip
  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
  disk_size    = var.disk_size
  zones        = var.zones

  depends_on = [module.vnet, module.acr]
}
