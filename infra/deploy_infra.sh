#!/usr/bin/env bash
set -euo pipefail
RG_NAME=${1:-odoo-rg}
LOCATION=${2:-westeurope}
PREFIX=${3:-odoo}
ADMIN_USERNAME=${4:-odooadmin}
SSH_KEY_PATH=${5:-~/.ssh/id_rsa.pub}

if [ ! -f "$SSH_KEY_PATH" ]; then
  echo "SSH key not found at $SSH_KEY_PATH"; exit 1
fi

SSH_PUB_KEY=$(cat "$SSH_KEY_PATH")

az group create -n $RG_NAME -l $LOCATION

az deployment group create \
  -g $RG_NAME \
  --template-file infra/main.bicep \
  --parameters prefix=$PREFIX adminUsername=$ADMIN_USERNAME adminPublicKey="$SSH_PUB_KEY" location=$LOCATION

echo "✅ Infra deployment done. Run 'az resource list -g $RG_NAME' to check resources."
