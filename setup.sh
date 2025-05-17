#!/usr/bin/env sh

# Nginx
mkdir -p /var/www/html
echo "<h1>Render VPN Server</h1>" > /var/www/html/index.html

cat > /etc/nginx/nginx.conf <<EOF
events {}
http {
    server {
        listen 80;
        root /var/www/html;
    }
}
EOF
nginx -g "daemon off;" &

# Tailscale (userspace-режим)
mkdir -p /var/lib/tailscale
tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state &
sleep 5  # Даем демону время на запуск
tailscale up --authkey "$TAILSCALE_AUTH_KEY"

# TFTP-сервер
mkdir -p /tftpboot
chmod 777 /tftpboot
echo "Test file" > /tftpboot/test.txt
in.tftpd --foreground --port 69 --secure /tftpboot &

# Keep-alive
while true; do
  curl -s http://localhost || true
  sleep 300
done
