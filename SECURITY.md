# Security Policy

## Secrets

Do not commit live `terraform.tfvars`, credentials, inventories, vault password
files, or decrypted Ansible Vault files. Store service secrets in ignored
`group_vars/<service>/vault.yml` files and encrypt them with `ansible-vault`.

Passwords previously committed to this repository must be treated as exposed.
Rotate them before using the project against real infrastructure. Removing them
from the current branch does not remove them from Git history.

## Network Access

SSH and Kubernetes API source ranges must be restricted to trusted `/32` CIDRs
or private VPN/network ranges. Terraform validation rejects world-open
administrative access.

## Reporting

Do not open a public issue containing credentials or infrastructure access
details. Revoke exposed credentials first, then report the affected component.
