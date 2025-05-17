export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y curl tftpd-hpa nginx

echo '<h1>Render VPN Server</h1>' > /var/www/html/index.html
echo 'server { listen 80; server_name _; root /var/www/html; index index.html; }' > /etc/nginx/sites-available/default
systemctl enabl#!/bin/bash

# Установка Nginx (для Render Web Service)
echo "Устанавливаем Nginx..."
apt-get update && apt-get install -y nginx
echo "<h1>Render VPN Server</h1>" > /var/www/html/index.html
service nginx start

# Установка Tailscale
echo "Устанавливаем Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --authkey $TAILSCALE_AUTH_KEY

# TFTP-сервер (используем busybox)
echo "Настраиваем TFTP-сервер..."
mkdir -p /var/tftpboot
chmod 777 /var/tftpboot
echo "Test file" > /var/tftpboot/test.txt
busybox udpsvd -E 0 69 busybox tftpd /var/tftpboot &

# Keep-alive скрипт
echo "Запускаем keep-alive..."
while true; do
  ping -c 1 8.8.8.8
  sleep 300
donee nginx
systemctl start nginx

curl -fsSL https://tailscale.com/install.sh | sh
systemctl enable tailscaled
tailscale up --authkey $TAILSCALE_AUTH_KEY

mkdir /var/lib/tftpboot
chmod 777 /var/lib/tftpboot
echo 'TFTP_USERNAME="tftp"\nTFTP_DIRECTORY="/var/lib/tftpboot"\nTFTP_ADDRESS=":69"\nTFTP_OPTIONS="--secure"' > /etc/default/tftpd-hpa
echo "Test file" > /var/lib/tftpboot/test.txt
systemctl enable tftpd-hpa
systemctl restart tftpd-hpa

echo "while true; do ping -c 1 8.8.8.8; sleep 300; done" > /keep-alive.sh
chmod +x /keep-alive.sh
nohup /keep-alive.sh &

ufw allow 80/tcp
ufw allow 69/udp
ufw allow 41641/udp
