# odoo
Odoo on Azure with monitoring, backups to Azure Blob Storage, Key Vault for secrets, SSL, firewall, IAM, Grafana, and security best practices. I’ll target Ubuntu 22.04 LTS for all VMs (so you don’t hit “pro” image confusion) . Paste into your repo and adapt variables (resource names, domains, secrets).
# Odoo on Azure — Deployment, Monitoring & Backup

Automated deployment of **Odoo** on **Azure** using **Bicep** for infra, **Ansible** for config, and scripts for backup/restore to Azure Blob Storage. Includes security best-practices: SSL, Azure Key Vault, IAM, Azure Firewall / NSG, Azure Monitor + Grafana.

- Target OS: **Ubuntu 22.04 LTS**
- DB: PostgreSQL (Azure Database for PostgreSQL Flexible Server recommended)
- Backups: daily PostgreSQL dumps to Azure Blob Storage
- Monitoring: Azure Monitor + Log Analytics + Azure Managed Grafana

See `docs/` for detailed architecture, backup & security guides.

## Quick flow
1. `infra/deploy_infra.sh` → create resource group, VNet, VM(s), storage account, Key Vault.
2. `provision/ansible/playbook-odoo.yml` → configure Odoo, Nginx, systemd, metrics.
3. `provision/scripts/postgresql_backup_to_blob.sh` → schedule daily backups to blob with retention.
4. Use Key Vault to store DB credentials & Odoo secrets (referenced by Ansible).

## Notes
- Update `infra/parameters.example.json` before provisioning.
- Use Ubuntu 22.04 image name (no “Pro” suffix) in Bicep.

## Extra recommendations & operational notes

-Use Azure Managed PostgreSQL (Flexible Server) with private endpoint and store credentials in Key Vault. If you run PostgreSQL on a VM, secure it and bind to private IP.

-Use Managed Identity on the VM and grant Storage Blob Data Contributor on the Storage Account to upload backups without embedding keys.

-Use Azure Managed Grafana (preview/GA depending on region) to connect to Log Analytics and Prometheus metrics.

-Application Gateway + WAF in front of Nginx for security and central TLS offload (recommended for production).

-Enable Azure Monitor alerts for backup failures & high DB errors.

-Test restore regularly and keep at least 3 copies (hot/cool/archive).
