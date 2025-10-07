# Odoo on Azure — Security Best Practices

1. **Use Ubuntu 22.04 LTS** (image referenced explicitly in Bicep).
2. **Azure Database for PostgreSQL** (Flexible Server) with private endpoint — avoid exposing DB to internet.
3. **Azure Key Vault** to store DB credentials, SMTP & secrets; grant VM access via Managed Identity.
4. **SSL/TLS**: use Azure App Gateway or Let's Encrypt on Nginx. Prefer Application Gateway with WAF for production.
5. **Network security**:
   - NSGs to restrict traffic to necessary ports (80/443, 8069 internal).
   - Consider Azure Firewall if multiple subnets/subscriptions.
6. **IAM / RBAC**:
   - Use least-privilege roles for users. Use managed identities for Azure resources.
7. **Monitoring & Alerts**:
   - Enable Azure Monitor, set alerts for CPU, memory, DB failover, backup failure.
8. **Backup & DR**:
   - Daily backups to Blob, periodic restore tests.
9. **OS & Application updates**:
   - Automated patching (Update Management).
10. **Audit & Logging**:
   - Enable diagnostic settings to send logs to Log Analytics or Event Hub.
