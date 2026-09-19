resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Name = var.vnet_name
  }
}

# Node subnet for the AKS cluster. With Azure CNI (or "Azure CNI powered by
# Cilium"), pods draw IPs from this subnet too, so size it generously —
# a /21 or larger is typical, well beyond what the equivalent EKS subnet needed.
resource "azurerm_subnet" "nodes" {
  name                 = "${var.vnet_name}-nodes"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.node_subnet_cidr]
}

resource "azurerm_network_security_group" "nodes" {
  name                = "${var.vnet_name}-nodes-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  # AKS injects the rules it needs (LB health probes, etc.) into this NSG
  # itself at cluster-create time — we just seed a deny-by-default posture.
  # No inbound-from-internet rules: nodes have no public IPs on this cluster.
}

resource "azurerm_subnet_network_security_group_association" "nodes" {
  subnet_id                 = azurerm_subnet.nodes.id
  network_security_group_id = azurerm_network_security_group.nodes.id
}

# --- Egress for the private cluster ---
# Private nodes have no public IPs, so image pulls, Azure API calls, OS
# updates, etc. all need a controlled way out. NAT Gateway is the
# recommended `outboundType` here instead of the default LB outbound rules.
resource "azurerm_public_ip" "nat" {
  name                = "${var.vnet_name}-nat-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
}

resource "azurerm_nat_gateway" "nat" {
  name                = "${var.vnet_name}-natgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  zones               = var.zones
}

resource "azurerm_nat_gateway_public_ip_association" "nat" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "nodes" {
  subnet_id      = azurerm_subnet.nodes.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
