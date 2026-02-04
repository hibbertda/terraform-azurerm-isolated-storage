## OUTPUTS
# Storage Account Private IP
output "isolated_storage_private_ip" {
  value = azurerm_private_endpoint.isolated_storage_pe.private_service_connection[0].private_ip_address
}
# Reader Group Object ID for Access Management
output "isolated_storage_reader_group_object_id" {
  value = azuread_group.isolated_storage_reader_access_group.object_id
}
# Reader Group Name for Access Management
output "isolated_storage_reader_group_name" { 
  value = azuread_group.isolated_storage_reader_access_group.display_name
}
# Contributor Group Object ID for Access Management
output "isolated_storage_contributor_group_object_id" {
  value = azuread_group.isolated_storage_access_group.object_id
}
# Contributor Group Name for Access Management
output "isolated_storage_contributor_group_name" { 
  value = azuread_group.isolated_storage_access_group.display_name
}