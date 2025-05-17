#!/bin/sh

# Установка Nginx для Alpine
echo "Устанавливаем Nginx..."
apk add nginx
mkdir -p /var/www/html
echo '<h1>Render VPN Server</h1>' > /var/www/html/index.html

# Конфиг Nginx для Alpine
cat > /etc/nginx/nginx.conf <<EOF
events {}
http {
    server {
        listen 80;
        root /var/www/html;
        index index.html;
    }
}
EOF

# Запуск Nginx
nginx

# Установка Tailscale (без прав root)
echo "Устанавливаем Tailscale..."
apk add tailscale
tailscaled --state=/var/lib/tailscale/tailscaled.state &
tailscale up --authkey $TAILSCALE_AUTH_KEY

# TFTP-сервер через busybox
echo "Настраиваем TFTP-сервер..."
mkdir -p /home/render/tftpboot
echo "Test file" > /home/render/tftpboot/test.txt
busybox udpsvd -E 0:69 busybox tftpd /home/render/tftpboot &

# Keep-alive без фонового режима
echo "Запускаем keep-alive..."
while true; do
  ping -c 1 8.8.8.8
  sleep 300
done
