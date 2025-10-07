# Backup & Restore

## Backup
- Use `postresql_backup_to_blob.sh` on a schedule (cron or Azure Automation).
- Prefer using a managed identity on the VM and SAS tokens or Storage Account keys stored in Key Vault.

## Restore
- Download blob using `az storage blob download` then `pg_restore`.
- Always test restores in a staging environment before production.

## Retention & Encryption
- Enable Blob lifecycle to move older backups to cool/archive tiers.
- Enable Storage encryption (default).
