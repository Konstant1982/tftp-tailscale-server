#!/bin/bash

# Установка неинтерактивного режима
export DEBIAN_FRONTEND=noninteractive

# Обновление и установка зависимостей
apt update
apt install -y curl tftpd-hpa nginx

# Настройка Nginx (HTTP)
echo '<h1>Render VPN Server</h1>' > /var/www/html/index.html
echo 'server { listen 80; server_name _; root /var/www/html; index index.html; }' > /etc/nginx/sites-available/default
systemctl enable nginx
systemctl start nginx

# Установка Tailscale
curl -fsSL https://tailscale.com/install.sh | sh
systemctl enable tailscaled
tailscale up --authkey $TAILSCALE_AUTH_KEY

# Настройка TFTP
mkdir /var/lib/tftpboot
chmod 777 /var/lib/tftpboot
echo 'TFTP_USERNAME="tftp"\nTFTP_DIRECTORY="/var/lib/tftpboot"\nTFTP_ADDRESS=":69"\nTFTP_OPTIONS="--secure"' > /etc/default/tftpd-hpa
echo "Test file" > /var/lib/tftpboot/test.txt
systemctl enable tftpd-hpa
systemctl restart tftpd-hpa

# Keep-alive скрипт (для UDP/Tailscale)
echo "while true; do ping -c 1 8.8.8.8; sleep 300; done" > /keep-alive.sh
chmod +x /keep-alive.sh
nohup /keep-alive.sh &

# Открытие портов
ufw allow 80/tcp
ufw allow 69/udp
ufw allow 41641/udp
