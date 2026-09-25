variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_id" {
  description = "Needed to link the private DNS zone into the VNet"
  type        = string
}

variable "node_subnet_id" {
  type = string
}

variable "acr_id" {
  description = "Resource ID of the ACR, for the AcrPull role assignment"
  type        = string
}

variable "system_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_size" {
  description = "AKS node pools take a single VM size, unlike EKS's list of candidate instance types"
  type        = string
}

variable "node_group_name" {
  type = string
}

variable "capacity_type" {
  type    = string
  default = "ON_DEMAND" # or "SPOT"
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

variable "zones" {
  type    = list(string)
  default = ["1", "2", "3"]
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
