#------------------------------------------------------------------------------
# Azure Policy Definition - Blocked Role Definitions
#------------------------------------------------------------------------------

resource "azurerm_policy_definition" "blocked_role_definitions" {
  name         = "isolated-storage-blocked-role-definitions"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Isolated Storage - Blocked Role Definitions"
  description  = "Blocks assignment of specified RBAC roles on isolated storage resources. Use this policy to prevent overly permissive role assignments (e.g., Contributor, Owner) to storage accounts with private endpoint access."

  metadata = jsonencode({
    category = "Authorization"
    version  = "1.0.0"
  })

  parameters = jsonencode({
    roleDefinitionIds = {
      type = "array"
      metadata = {
        description  = "The list of blocked role definition resource IDs that cannot be assigned (e.g. /providers/Microsoft.Authorization/roleDefinitions/<guid>)."
        displayName  = "Blocked Role Definitions"
      }
    }
    exemptPrincipalIds = {
      type         = "array"
      defaultValue = []
      metadata = {
        description  = "Optional list of Microsoft Entra ID objectIds for exempt principals (users and/or groups). If the role assignment principalId is in this list, the assignment is exempt from the blocked role definition list."
        displayName  = "Exempt principals (users/groups objectIds)"
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Authorization/roleAssignments"
        },
        {
          field = "Microsoft.Authorization/roleAssignments/roleDefinitionId"
          in    = "[parameters('roleDefinitionIds')]"
        },
        {
          not = {
            field = "Microsoft.Authorization/roleAssignments/principalId"
            in    = "[parameters('exemptPrincipalIds')]"
          }
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

#------------------------------------------------------------------------------
# Policy Assignment (optional - assign to resource group scope)
#------------------------------------------------------------------------------

resource "azurerm_resource_group_policy_assignment" "blocked_role_definitions" {
  count                = var.enable_rbac_policy_assignment ? 1 : 0
  name                 = "blocked-role-definitions-assignment"
  resource_group_id    = azurerm_resource_group.isolated_storage_rg.id
  policy_definition_id = azurerm_policy_definition.blocked_role_definitions.id
  description          = "Blocks assignment of specified roles on isolated storage resources"
  display_name         = "Blocked Role Definitions Assignment"

  non_compliance_message {
    content = "Data access restricted to this resource"
  }

  depends_on = [ 
    azurerm_storage_account.isolated,
    azuread_group.isolated_storage_access_group,
    azuread_group.isolated_storage_reader_access_group,
    azuread_group.isolated_storage_owner_access_group
    ]

  parameters = jsonencode({
    roleDefinitionIds = { value = var.blocked_role_definition_ids }
    exemptPrincipalIds = {
      value = [
        # Exempt the EntraID groups created for storage account access management 
        # to avoid blocking necessary role assignments for the module's functionality
        azuread_group.isolated_storage_access_group.object_id,
        azuread_group.isolated_storage_reader_access_group.object_id,
        azuread_group.isolated_storage_owner_access_group.object_id
      ]
    }
  })
}
