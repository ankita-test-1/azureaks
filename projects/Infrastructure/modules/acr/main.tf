variable "repositories" {
  type        = list(string)
  description = "Logical list of image repo names that will live in this registry (informational only)"
  default     = []
}

resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled        = false # prefer AKS kubelet managed identity / RBAC pulls over admin username+password
}
