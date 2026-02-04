# Example variable values for the Isolated Storage Account module
# Copy this file to terraform.tfvars and update with your values

primary_region                        = "eastus"
ipv4_range                            = "10.100.0.0/24"
primary_region_vnet_name              = "vnet-primary-eastus"
primary_resource_group                = "rg-primary-eastus"
network_security_perimeter_profile_id = "/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.Network/networkSecurityPerimeters/<nsp-name>/profiles/<profile-name>"

resource_tags = {
  environment = "production"
  project     = "isolated-storage"
  owner       = "your-team"
}
