#!/usr/bin/env bash
set -euo pipefail
# Usage: restore_from_blob.sh <blob-name> <container> <storage-account> <conn-string>
BLOB_NAME=$1
CONTAINER=${2:-odoo-backups}
AZURE_CONN_STRING=${3:-}

TMP_DIR="/tmp/odoo_restore"
mkdir -p $TMP_DIR
az storage blob download --connection-string "$AZURE_CONN_STRING" --container-name "$CONTAINER" --name "$BLOB_NAME" --file "${TMP_DIR}/${BLOB_NAME}"

gunzip -c "${TMP_DIR}/${BLOB_NAME}" | sudo -u postgres pg_restore -d odoo --clean --if-exists
echo "✅ Restore complete"
