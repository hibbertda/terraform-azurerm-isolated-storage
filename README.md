# Isolated Azure Storage Account Module

This Terraform module creates a secure, isolated Azure Storage Account with private network access, designed to protect data and strictly control access through multiple layers of security.

## Features

- **Isolated Virtual Network**: Creates a dedicated VNet with workload and private endpoint subnets
- **Private Endpoint Access**: Storage account accessible only via private endpoint (no public internet exposure)
- **Private DNS Zone**: Automatic DNS resolution for private endpoint connectivity
- **Virtual Network (VNet) Peering**: Bidirectional peering to primary region VNet with gateway transit support for on-premises access via VPN
- **Network Security Perimeter (NSP)**: Enforced NSP association for additional network-level security controls
- **Entra ID Access Control**: Automatically creates security groups with RBAC role assignments
- **Security Hardening**:
  - HTTPS-only traffic enforced
  - Shared access keys disabled (Entra ID authentication required)
  - Public blob access disabled
  - Public network access disabled
  - Cross-tenant replication disabled
  - Infrastructure encryption enabled (double encryption)
  - Default outbound access disabled on subnets

## Security Considerations

### Access Control
- **Entra ID Authentication**: Shared access keys are disabled; use Azure AD/Entra ID for authentication
- **Security Groups**: Module creates two Entra ID security groups:
  - `ISA-{storage-account-name}-contributor-group` — Storage Blob Data Contributor role
  - `ISA-{storage-account-name}-reader-group` — Storage Blob Data Reader role
- **Role Based Access Control (RBAC)**: Add users/service principals to these groups to grant access
- **Network Security Perimeter (NSP)**: NSP is enforced to control inbound/outbound network access

### Network Isolation
- Public network access is disabled on the storage account
- Storage is only accessible via private endpoint
- VNet peering enables access from the primary region and connected on-premises networks via VPN gateway
- Subnets have default outbound access disabled for enhanced security

### Data Protection
- HTTPS-only traffic enforcement
- Infrastructure encryption enabled (double encryption at rest)
- Cross-tenant replication disabled
- Public blob access is disabled
- Last access time tracking enabled for lifecycle management

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Isolated Storage VNet                         │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐ │
│  │   Workload Subnet   │    │   Private Endpoint Subnet       │ │
│  │                     │    │   ┌───────────────────────────┐ │ │
│  │                     │    │   │  Private Endpoint (Blob)  │ │ │
│  └─────────────────────┘    │   └───────────────────────────┘ │ │
│                             └─────────────────────────────────┘ │
└───────────────────────────────┬─────────────────────────────────┘
                                │ VNet Peering
                                │ (Gateway Transit)
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Primary Region VNet                           │
│                    (With VPN Gateway)                            │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
                        On-Premises Network
```
## Prerequisites

1. **Primary Region VNet with VPN Gateway**: This module expects an existing VNet with a VPN gateway for on-premises connectivity
2. **Network Security Perimeter**: An existing NSP profile must be created before deploying this module
3. **Sufficient IP Space**: Ensure the `ipv4_range` CIDR does not overlap with existing networks

## Usage

```hcl
module "isolated_storage" {
  source = "./modules/isolated_storage"

  primary_region                        = "eastus"
  ipv4_range                            = "10.100.0.0/24"
  primary_region_vnet_name              = "vnet-primary-eastus"
  primary_resource_group                = "primary-rg"
  network_security_perimeter_profile_id = "/subscriptions/.../networkSecurityPerimeters/.../profiles/..."
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |
| azuread | >= 2.0 |
| random | >= 3.0 |

## Providers

| Name | Description |
|------|-------------|
| azurerm | Azure Resource Manager provider |
| azuread | Azure Active Directory / Entra ID provider |
| random | Random string generation for storage account naming |

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `ipv4_range` | CIDR block for the isolated storage VNet (e.g., `10.100.0.0/24`) | `string` | Yes |
| `network_security_perimeter_profile_id` | Resource ID of the Network Security Perimeter profile | `string` | Yes |
| `primary_region` | Azure region for deployment | `string` | Yes |
| `primary_region_vnet_name` | Name of the primary region VNet to peer with | `string` | Yes |
| `primary_resource_group` | Resource group containing the primary region VNet | `string` | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `isolated_storage_private_ip` | Private IP address of the storage account's private endpoint |
| `isolated_storage_reader_group_object_id` | Object ID of the Entra ID reader group |
| `isolated_storage_reader_group_name` | Display name of the Entra ID reader group |
| `isolated_storage_contributor_group_object_id` | Object ID of the Entra ID contributor group |
| `isolated_storage_contributor_group_name` | Display name of the Entra ID contributor group |

## Resources Created

| Resource | Description |
|----------|-------------|
| `azurerm_resource_group` | Dedicated resource group for isolated storage |
| `azurerm_virtual_network` | Isolated VNet for secure storage access |
| `azurerm_subnet` (x2) | Workload and Private Endpoint subnets |
| `azurerm_virtual_network_peering` (x2) | Bidirectional peering with primary VNet |
| `azurerm_storage_account` | Storage account with security hardening |
| `azurerm_private_dns_zone` | Private DNS zone for blob.core.windows.net |
| `azurerm_private_dns_zone_virtual_network_link` | DNS zone link to isolated VNet |
| `azurerm_private_endpoint` | Private endpoint for blob storage |
| `azurerm_private_dns_a_record` | DNS A record for private endpoint resolution |
| `azurerm_network_security_perimeter_association` | NSP association (Enforced mode) |
| `azuread_group` (x2) | Entra ID security groups for contributor and reader access |
| `azurerm_role_assignment` (x2) | RBAC role assignments for storage blob access |


## Notes

- Storage account names are randomly generated (12 characters, lowercase alphanumeric)
- The module creates its own resource group named `isolated-storage-{region}`
- VNet peering uses gateway transit to leverage the primary region's VPN gateway for on-premises access
