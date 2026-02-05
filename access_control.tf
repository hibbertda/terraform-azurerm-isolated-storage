## Access Control
# Create EntraID Group for Storage Account Access
resource "azuread_group" "isolated_storage_access_group" {
  display_name     = "ISA-${azurerm_storage_account.isolated.name}-contributor-group"
  security_enabled = true
  mail_enabled     = false
  description      = "Group for managing access to the isolated storage account"
}
# Assign Storage Blob Data Contributor Role to EntraID Group
resource "azurerm_role_assignment" "isolated_storage_blob_data_contributor_assignment" {
  scope                = azurerm_storage_account.isolated.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_group.isolated_storage_access_group.object_id
}
#------------------------------------------------------------------------------
# Create EntraID Group for Storage Account Reader Access
resource "azuread_group" "isolated_storage_reader_access_group" {
  display_name     = "ISA-${azurerm_storage_account.isolated.name}-reader-group"
  security_enabled = true
  mail_enabled     = false
  description      = "Group for read-only access to the isolated storage account"
}
# Assign Storage Account Reader Role to EntraID Group
resource "azurerm_role_assignment" "isolated_storage_account_reader_assignment" {
  scope                = azurerm_storage_account.isolated.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azuread_group.isolated_storage_reader_access_group.object_id
}
#------------------------------------------------------------------------------
# Create EntraID Group for Storage Account Owner Access (optional - for full control)
resource "azuread_group" "isolated_storage_owner_access_group" {
  display_name     = "ISA-${azurerm_storage_account.isolated.name}-owner-group"
  security_enabled = true
  mail_enabled     = false
  description      = "Group for full control access to the isolated storage account"
}
# Assign Storage Account Owner Role to EntraID Group (optional - for full control)
resource "azurerm_role_assignment" "isolated_storage_account_owner_assignment" {
  scope                = azurerm_storage_account.isolated.id
  role_definition_name = "Storage Account Owner"
  principal_id         = azuread_group.isolated_storage_owner_access_group.object_id
}