output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "node_subnet_id" {
  value = azurerm_subnet.nodes.id
}

# Kept as a list for interface parity with the old module, and so it's easy
# to extend later (separate subnets per node pool, private endpoints, etc.)
output "subnet_ids" {
  value = [azurerm_subnet.nodes.id]
}


output "nat_gateway_public_ip" {
  value = azurerm_public_ip.nat.ip_address
}
