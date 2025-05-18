#!/usr/bin/env sh

# Nginx (HTTP-сервер)
mkdir -p /var/www/html /var/www/html/fs
echo "<h1>Render VPN Server</h1>" > /var/www/html/index.html

cat > /etc/nginx/nginx.conf <<EOF
events {}
http {
    server {
        listen 80;
        root /var/www/html;
        location /fs/ {
            autoindex on;
        }
    }
}
EOF
nginx -g "daemon off;" &

# Tailscale (userspace-режим)
mkdir -p /var/lib/tailscale
echo "Starting tailscaled..."
tailscaled --tun=userspace-networking --state=/var/lib/tailscale/tailscaled.state --port 41641 --verbose=1 &
TAILSCALED_PID=$!
sleep 5  # Даем демону время на запуск

# Проверка, что tailscaled работает
if ! ps | grep -q "[t]ailscaled"; then
    echo "Error: tailscaled failed to start. Check logs."
    exit 1
fi

echo "Running tailscale up..."
tailscale up --authkey "$TAILSCALE_AUTH_KEY" --accept-dns=false --advertise-exit-node
if [ $? -ne 0 ]; then
    echo "Error: tailscale up failed. Check network or auth key."
    exit 1
fi
tailscale status || echo "Tailscale status check failed"

# TFTP-сервер
mkdir -p /tftpboot /tftpboot/fs
chmod 777 /tftpboot /tftpboot/fs
echo "Test file" > /tftpboot/test.txt
if [ -f /kernel_x86_64.efi ]; then
    cp /kernel_x86_64.efi /tftpboot/fs/kernel_x86_64.efi
    cp /kernel_x86_64.efi /var/www/html/fs/kernel_x86_64.efi
    chmod 777 /tftpboot/fs/kernel_x86_64.efi /var/www/html/fs/kernel_x86_64.efi
else
    echo "Error: /kernel_x86_64.efi not found in container"
fi
if [ -f /kernel_x86_64.elf ]; then
    cp /kernel_x86_64.elf /tftpboot/fs/kernel_x86_64.elf
    cp /kernel_x86_64.elf /var/www/html/fs/kernel_x86_64.elf
    chmod 777 /tftpboot/fs/kernel_x86_64.elf /var/www/html/fs/kernel_x64.elf
else
    echo "Error: /kernel_x86_64.elf not found in container"
fi

in.tftpd --foreground --port 69 --secure /tftpboot &

# Keep-alive
while true; do
    curl -s http://localhost || true
    sleep 300
done
