variable "location" {
  description = "Azure region, e.g. eastus"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will hold everything in this project"
  type        = string
}

variable "subscription_id" {
  description = "Leave null to fall back to ARM_SUBSCRIPTION_ID / az cli context"
  type        = string
  default     = null
}

# --- VNet ---

variable "vnet_name" {
  type = string
}

variable "address_space" {
  description = "VNet CIDR, e.g. 10.1.0.0/16"
  type        = string
}

variable "node_subnet_cidr" {
  description = "CIDR for the AKS node subnet"
  type        = string
}

variable "zones" {
  description = "Availability zones used by the NAT Gateway and node pools"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "enable_bastion_subnet" {
  type    = bool
  default = false
}

variable "bastion_subnet_cidr" {
  type    = string
  default = null
}

# --- AKS ---

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the user node pool"
  type        = string
}

variable "system_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_size" {
  description = "VM size for the user node pool"
  type        = string
}

variable "pod_cidr" {
  description = "VM size for the user node pool"
  type        = string
}

variable "service_cidr" {
  description = "VM size for the user node pool"
  type        = string
}

variable "dns_service_ip" {
  description = "VM size for the user node pool"
  type        = string
}

variable "capacity_type" {
  description = "ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "disk_size" {
  type    = number
  default = 30
}

# --- ACR ---

variable "acr_name" {
  description = "Globally unique registry name, alphanumeric only (no hyphens), 5-50 chars"
  type        = string
}

variable "acr_sku" {
  type    = string
  default = "Standard"
}

variable "repositories" {
  description = "Logical list of repo names that will be pushed to the registry (informational only)"
  type        = list(string)
  default     = []
}
