# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-02-04

### Added
- Initial release of the Isolated Azure Storage Account module
- Isolated Virtual Network with workload and private endpoint subnets
- Private endpoint access for blob storage (no public internet exposure)
- Private DNS zone with automatic A record for endpoint resolution
- Bidirectional VNet peering to primary region VNet with gateway transit support
- Network Security Perimeter (NSP) association in enforced mode
- Entra ID security groups with RBAC role assignments:
  - Contributor group with Storage Blob Data Contributor role
  - Reader group with Storage Blob Data Reader role
- Security hardening features:
  - HTTPS-only traffic enforcement
  - Shared access keys disabled
  - Public blob access disabled
  - Public network access disabled
  - Cross-tenant replication disabled
  - Infrastructure encryption enabled
  - Default outbound access disabled on subnets
