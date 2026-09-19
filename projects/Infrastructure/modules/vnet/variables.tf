variable "vnet_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  description = "VNet CIDR, e.g. 10.0.0.0/16"
  type        = string
}

variable "node_subnet_cidr" {
  description = "CIDR for the AKS node/pod subnet. Size generously — Azure CNI hands pods IPs from this subnet too."
  type        = string
}

variable "zones" {
  description = "Availability zones for the NAT Gateway's public IP"
  type        = list(string)
  default     = ["1", "2", "3"]
}
