variable "acr_name" {
  type        = string
  description = "Globally unique registry name (alphanumeric only, no hyphens, 5-50 chars) — becomes <name>.azurecr.io"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the registry in"
}

variable "location" {
  type        = string
  description = "Azure region, e.g. eastus"
}

variable "sku" {
  type        = string
  description = "Basic, Standard, or Premium. Premium is required for geo-replication and private endpoints."
  default     = "Standard"
}

# Kept only so downstream code/docs can enumerate what will be pushed here.
# Unlike aws_ecr_repository, ACR has no per-repository resource to create —
# repos are created implicitly the first time an image is pushed.
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
  admin_enabled       = false # prefer AKS kubelet managed identity / RBAC pulls over admin username+password
}
