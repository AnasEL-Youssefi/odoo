#!/usr/bin/env bash
set -euo pipefail
# Expects AZURE_LOG_ANALYTICS_WORKSPACE_ID and AZURE_LOG_ANALYTICS_SHARED_KEY env vars to be set
if [ -z "${AZURE_LOG_ANALYTICS_WORKSPACE_ID:-}" ]; then echo "Set AZURE_LOG_ANALYTICS_WORKSPACE_ID"; exit 1; fi
if [ -z "${AZURE_LOG_ANALYTICS_SHARED_KEY:-}" ]; then echo "Set AZURE_LOG_ANALYTICS_SHARED_KEY"; exit 1; fi

wget https://raw.githubusercontent.com/microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh -O onboard_agent.sh
sudo sh onboard_agent.sh -w "$AZURE_LOG_ANALYTICS_WORKSPACE_ID" -s "$AZURE_LOG_ANALYTICS_SHARED_KEY"

# Optionally install node_exporter and prometheus node exporter for Grafana metrics
# Install node exporter (systemd service)
sudo useradd -rs /bin/false node_exporter || true
NODE_EXPORTER_VER="1.6.1"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VER}/node_exporter-${NODE_EXPORTER_VER}.linux-amd64.tar.gz
tar xvf node_exporter-*.tar.gz
sudo mv node_exporter-*/node_exporter /usr/local/bin/
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=default.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
echo "✅ Log Analytics and node_exporter installed"
