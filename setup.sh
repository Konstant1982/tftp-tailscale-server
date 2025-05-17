#!/usr/bin/env sh

# Nginx
mkdir -p /var/www/html
echo "<h1>Render VPN Server</h1>" > /var/www/html/index.html

cat > /etc/nginx/nginx.conf <<EOF
events {}#!/usr/bin/env sh

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
nginx

# Tailscale (запуск с явным указанием сокета)
tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
sleep 10  # Увеличили задержку для инициализации демона
tailscale up --authkey=$TAILSCALE_AUTH_KEY --hostname=render-vpn

# TFTP-сервер
mkdir -p /tftpboot
echo "Test file" > /tftpboot/test.txt
busybox udpsvd -E 0:69 busybox tftpd /tftpboot &

# Keep-alive через HTTP-запросы (без ping)
while true; do
  wget -qO- http://google.com >/dev/null 2>&1 || true
  sleep 300
done
http {
    server {
        listen 80;
        root /var/www/html;
    }
}
EOF
nginx

# Tailscale
tailscaled --state=/var/lib/tailscale/tailscaled.state > /dev/null 2>&1 &
sleep 5  # Даем демону время на запуск
tailscale up --authkey $TAILSCALE_AUTH_KEY

# TFTP-сервер
mkdir -p /tftpboot
echo "Test file" > /tftpboot/test.txt
busybox udpsvd -E 0:69 busybox tftpd /tftpboot > /dev/null 2>&1 &

# Keep-alive
while true; do
  ping -c 1 8.8.8.8 > /dev/null
  sleep 300
done
