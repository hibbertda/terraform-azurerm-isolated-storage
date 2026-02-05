## MODULE: Isolated Secure Storage Account with Private Endpoint and VNET Peering

locals {
  local_tags = {
    tf_module = "IsolatedStorage"
  }
}

# Resource Data Sources
data "azurerm_resource_group" "primary_region_rg" {
  name = var.primary_resource_group
}

data "azurerm_virtual_network" "primary_region_vnet" {
  name                = var.primary_region_vnet_name
  resource_group_name = var.primary_resource_group
}
# Current Subscription Data Source (for subscription-scoped policy assignment)
data "azurerm_subscription" "current" {}

# Resource Group for Isolated Storage
resource "azurerm_resource_group" "isolated_storage_rg" {
  name     = "isolated-storage-${var.primary_region}"
  location = var.primary_region

  tags = merge(
    local.local_tags,
    {
      environment = "Dev"
    }
  )
}

# Generate Random storage account name
resource "random_string" "storage_account_name" {
  length  = 12
  lower   = true
  upper   = false
  numeric = true
  special = false
}


