#!/usr/bin/env bash
set -euo pipefail
# Usage: install_odoo.sh <odoo-version> <db-host>
ODOO_VERSION=${1:-16.0}
DB_HOST=${2:-127.0.0.1}

sudo apt update && sudo apt install -y git python3 python3-venv python3-pip build-essential libpq-dev \
  libxml2-dev libxslt1-dev libffi-dev nodejs npm

sudo useradd -m -U -r -s /bin/bash odoo || true
sudo mkdir -p /opt/odoo
sudo chown odoo:odoo /opt/odoo

sudo -u odoo git clone --depth 1 --branch ${ODOO_VERSION} https://github.com/odoo/odoo.git /opt/odoo

sudo -u odoo python3 -m venv /opt/odoo/venv
sudo -u odoo /opt/odoo/venv/bin/pip install -r /opt/odoo/requirements.txt

sudo mkdir -p /var/log/odoo && sudo chown odoo:odoo /var/log/odoo

cat <<EOF | sudo tee /etc/odoo/odoo.conf
[options]
admin_passwd = superadminchangeme
db_host = ${DB_HOST}
db_port = 5432
db_user = odoo
db_password = odoo_pass
addons_path = /opt/odoo/addons
logfile = /var/log/odoo/odoo.log
EOF

cat <<EOF | sudo tee /etc/systemd/system/odoo.service
[Unit]
Description=Odoo
After=network.target

[Service]
Type=simple
User=odoo
ExecStart=/opt/odoo/venv/bin/python /opt/odoo/odoo-bin -c /etc/odoo/odoo.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now odoo
echo "✅ Odoo installed and started (version=${ODOO_VERSION})"
