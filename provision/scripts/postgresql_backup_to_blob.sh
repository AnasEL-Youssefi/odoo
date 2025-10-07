#!/usr/bin/env bash
set -euo pipefail
# Usage: postgresql_backup_to_blob.sh <container-name> <storage-account> <sas-or-conn-string>
CONTAINER=${1:-odoo-backups}
STORAGE_ACCOUNT=${2:-odooStorageAcct}
AZURE_CONN_STRING=${3:-}
BACKUP_DIR="/var/backups/odoo"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H%MZ")
mkdir -p $BACKUP_DIR

# postgres credentials must be available via env or .pgpass
PG_DUMP_FILE="${BACKUP_DIR}/odoo_backup_${TIMESTAMP}.sql.gz"
sudo -u postgres pg_dump -Fc odoo | gzip > ${PG_DUMP_FILE}

# upload using az cli (requires az login or SAS/conn string)
if [ -n "${AZURE_CONN_STRING}" ]; then
  az storage blob upload --connection-string "$AZURE_CONN_STRING" \
    --container-name "$CONTAINER" \
    --file "${PG_DUMP_FILE}" \
    --name "$(basename ${PG_DUMP_FILE})"
else
  echo "ERROR: Provide AZURE connection string as 3rd arg"
  exit 2
fi

# Optional: remove local older backups > retention_days
RETENTION_DAYS=14
find $BACKUP_DIR -type f -mtime +${RETENTION_DAYS} -delete
echo "✅ Backup uploaded: ${PG_DUMP_FILE}"
