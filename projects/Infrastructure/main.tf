resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source = "./modules/vpc" # rename to ./modules/vnet whenever you do the folder renames

  vnet_name             = var.vnet_name
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  address_space         = var.address_space
  node_subnet_cidr      = var.node_subnet_cidr
  zones                 = var.zones
  enable_bastion_subnet = var.enable_bastion_subnet
  bastion_subnet_cidr   = var.bastion_subnet_cidr
}

module "acr" {
  source = "./modules/ecr" # rename to ./modules/acr whenever you do the folder renames

  acr_name             = var.acr_name
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  sku                  = var.acr_sku
  repositories         = var.repositories
}

module "aks" {
  source = "./modules/eks" # rename to ./modules/aks whenever you do the folder renames

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

  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
  disk_size    = var.disk_size
  zones        = var.zones

  depends_on = [module.vnet, module.acr]
}

provider "kubernetes" {
  alias                  = "aks"
  host                   = module.aks.kube_config.host
  client_certificate     = base64decode(module.aks.kube_config.client_certificate)
  client_key             = base64decode(module.aks.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
}

provider "helm" {
  alias = "aks"

  kubernetes = {
    host                   = module.aks.kube_config.host
    client_certificate     = base64decode(module.aks.kube_config.client_certificate)
    client_key             = base64decode(module.aks.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
  }
}

module "argocd" {
  source = "./modules/argocd"

  providers = {
    kubernetes = kubernetes.aks
    helm       = helm.aks
  }

  depends_on = [module.aks]
}
