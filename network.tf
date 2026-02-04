## Isolated Network
# Virtual Network
resource "azurerm_virtual_network" "secure_storage_vnet" {
  name                = "vnet-secure-storage-${var.primary_region}"
  address_space       = [var.ipv4_range]
  location            = var.primary_region
  resource_group_name = azurerm_resource_group.isolated_storage_rg.name
}
# Workload Subnet
resource "azurerm_subnet" "secure_storage_workload_subnet" {
  name                 = "Workload"
  resource_group_name  = azurerm_resource_group.isolated_storage_rg.name
  virtual_network_name = azurerm_virtual_network.secure_storage_vnet.name
  
  address_prefixes     = [cidrsubnet(var.ipv4_range, 3, 1)]

  default_outbound_access_enabled = false
}
# Private Endpoint Subnet
resource "azurerm_subnet" "isolated_storage_pe_subnet" {
  name                 = "PrivateEndpoint"
  resource_group_name  = azurerm_resource_group.isolated_storage_rg.name
  virtual_network_name = azurerm_virtual_network.secure_storage_vnet.name

  address_prefixes = [cidrsubnet(var.ipv4_range, 3, 2)]

  default_outbound_access_enabled = false
}

# VNET Peering to Primary Region VNET
resource "azurerm_virtual_network_peering" "peering_to_primary_region_vnet" {
  name                      = "peering-to-primary-region-vnet"
  resource_group_name       = azurerm_resource_group.isolated_storage_rg.name
  virtual_network_name      = azurerm_virtual_network.secure_storage_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.primary_region_vnet.id
  allow_forwarded_traffic  = true
  allow_gateway_transit    = false
  use_remote_gateways      = true
}
# VNET Peering from Primary Region VNET
resource "azurerm_virtual_network_peering" "peering_from_primary_region_vnet" {
  name                      = "peering-from-primary-region-vnet"
  resource_group_name       = data.azurerm_resource_group.primary_region_rg.name
  virtual_network_name      = data.azurerm_virtual_network.primary_region_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.secure_storage_vnet.id
  allow_forwarded_traffic  = true
  allow_gateway_transit    = true
  use_remote_gateways      = false
}
