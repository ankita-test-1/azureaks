subscription_id     = "19956185-59a5-4243-b32d-572e96134d6e"
location            = "eastus"
resource_group_name = "aks-demo-rg"

vnet_name        = "aks-demo-vnet"
address_space    = "10.1.0.0/16"
node_subnet_cidr = "10.1.0.0/21" # generous even though overlay mode means pods don't consume it
zones            = ["1", "2", "3"]


cluster_name    = "aks-cluster"
node_group_name = "aks-node-pool"

system_vm_size = "Standard_B2s"
vm_size        = "Standard_D2s_v5"
capacity_type  = "ON_DEMAND"

desired_size = 1
min_size     = 1
max_size     = 2

disk_size = 30

acr_name = "aksregistryshopping" # must be globally unique across all of Azure
acr_sku  = "Standard"

repositories = [
  "frontend",
  "gateway",
  "auth",
  "order-service",
  "orders",
  "product-service",
  "user-service"
]
