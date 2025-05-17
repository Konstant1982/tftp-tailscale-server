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

# Tailscale
mkdir -p /var/lib/tailscale
tailscaled --state=/var/lib/tailscale/tailscaled.state &
sleep 5  # Даем демону время на запуск
tailscale up --authkey "$TAILSCALE_AUTH_KEY"

# TFTP-сервер
mkdir -p /tftpboot
echo "Test file" > /tftpboot/test.txt
busybox udpsvd -E 0 69 busybox tftpd /tftpboot &

# Keep-alive (заменяем ping на curl)
while true; do
  curl -s http://localhost || true
  sleep 300
done
