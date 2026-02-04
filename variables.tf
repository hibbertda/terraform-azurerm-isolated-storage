variable "ipv4_range" {
  description = "CIDR block for the isolated storage VNet (e.g., 10.100.0.0/24)"
  type        = string
  default     = "10.0.2.0/14"
}

variable "network_security_perimeter_profile_id" {
  description = "Resource ID of the Network Security Perimeter profile"
  type        = string
}

variable "primary_region" {
  description = "Azure region for deployment"
  type        = string
}

variable "primary_region_vnet_name" {
  description = "Name of the primary region VNet to peer with"
  type        = string
}

variable "primary_resource_group" {
  description = "Resource group containing the primary region VNet"
  type        = string
}

variable "resource_tags" {
  description = "Azure resource tags"
  type = map(string)
  default = {}
}