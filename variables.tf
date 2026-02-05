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

#------------------------------------------------------------------------------
# Azure Policy Variables
#------------------------------------------------------------------------------

variable "enable_rbac_policy_assignment" {
  description = "Whether to create the policy assignment for blocked role definitions"
  type        = bool
  default     = false
}

variable "blocked_role_definition_ids" {
  description = "List of blocked role definition resource IDs that cannot be assigned (e.g. /providers/Microsoft.Authorization/roleDefinitions/<guid>)"
  type        = list(string)
  default     = [
    # Storage Blob Data Owner
    "/providers/Microsoft.Authorization/roleDefinitions/b7e6dc6d-f1e8-4753-8033-0f276bb0955b",
    # Storage Blob Data Contributor
    "/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe",
    # Storage Blob Data Reader
    "/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1",
    # Storage Blob Delegator
    "/providers/Microsoft.Authorization/roleDefinitions/db58b8e5-c6ad-4a2a-8342-4190687cbf4a"
  ]
}