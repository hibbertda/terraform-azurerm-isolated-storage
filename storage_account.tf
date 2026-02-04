## Isolated Secure Storage Account
# Storage Account
resource "azurerm_storage_account" "isolated" {
  name                     = random_string.storage_account_name.result
  resource_group_name      = azurerm_resource_group.isolated_storage_rg.name
  location                 = var.primary_region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Dev"
    project     = "IsolatedStorage"
  }

  https_traffic_only_enabled        = true
  public_network_access_enabled     = false
  shared_access_key_enabled         = false
  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = true
  
  blob_properties {
    last_access_time_enabled = true
  }  
}

## Private Network for Isolated Access
# Private DNS Zone
resource "azurerm_private_dns_zone" "isolated_storage_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.isolated_storage_rg.name
}
# Virtual Network Link to VNET
resource "azurerm_private_dns_zone_virtual_network_link" "isolated_storage_dns_vnet_link" {
  name                  = "link-isolated-storage-vnet"
  resource_group_name   = azurerm_resource_group.isolated_storage_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.isolated_storage_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.secure_storage_vnet.id
  registration_enabled  = false
}

# Storage Private Endpoint
resource "azurerm_private_endpoint" "isolated_storage_pe" {
  name                = "pe-${azurerm_storage_account.isolated.name}"
  location            = var.primary_region
  resource_group_name = azurerm_resource_group.isolated_storage_rg.name
  subnet_id           = azurerm_subnet.isolated_storage_pe_subnet.id
  
  private_service_connection {
    name                           = "psc-${azurerm_storage_account.isolated.name}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.isolated.id
    subresource_names              = ["blob"]
  }
}
# Private DNS Zone A Record for Storage Account
resource "azurerm_private_dns_a_record" "isolated_storage_dns_a_record" {
  name                = azurerm_storage_account.isolated.name
  zone_name           = azurerm_private_dns_zone.isolated_storage_dns_zone.name
  resource_group_name = azurerm_resource_group.isolated_storage_rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.isolated_storage_pe.private_service_connection[0].private_ip_address]
}


# Associate NSP with Secure Storage Account
resource "azurerm_network_security_perimeter_association" "NSP_IsolatedStorage" {
  name = "nsp-${azurerm_storage_account.isolated.name}-association"
  access_mode = "Enforced"

  network_security_perimeter_profile_id = var.network_security_perimeter_profile_id
  resource_id                           = azurerm_storage_account.isolated.id
}
