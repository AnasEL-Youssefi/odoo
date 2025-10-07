#!/usr/bin/env bash
set -euo pipefail
DOMAIN=${1:-example.com}
EMAIL=${2:-admin@example.com}

sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

# Nginx reverse proxy (basic)
cat <<EOF | sudo tee /etc/nginx/sites-available/odoo
server {
    listen 80;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://127.0.0.1:8069;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/odoo || true
sudo nginx -t
sudo systemctl reload nginx

# Get certificates
sudo certbot --nginx -d ${DOMAIN} --non-interactive --agree-tos -m ${EMAIL}
sudo systemctl reload nginx

echo "✅ Nginx configured and SSL obtained for ${DOMAIN}"
