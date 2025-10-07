# Architecture Overview

- VNet with subnet(s)
- VM (Ubuntu 22.04) running Odoo + Nginx reverse proxy
- Azure Database for PostgreSQL (recommended) or PostgreSQL on separate VM
- Azure Storage Account (Blob) for backups
- Azure Key Vault for secrets (DB credentials, SMTP)
- Azure Monitor (Log Analytics) + Azure Managed Grafana for dashboards
- Optional: Application Gateway with WAF for HTTPS + rate limiting

Flow:
Client → Azure Firewall / App Gateway → Nginx (SSL) → Odoo (8069) → PostgreSQL
Backups: pg_dump -> upload to Blob (via az cli / managed identity)
Monitoring: metrics via node_exporter -> Prometheus -> Grafana; logs -> Log Analytics
