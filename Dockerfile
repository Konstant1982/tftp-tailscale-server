FROM alpine:latest

# Установка зависимостей с поддержкой TUN и сетевых утилит
RUN apk add --no-cache \
    nginx \
    tailscale \
    busybox-extras \  # Для udpsvd
    wget \
    iptables \
    ip6tables \
    linux-headers

# Копирование скрипта и настройка прав
COPY setup.sh /setup.sh
RUN chmod +x /setup.sh

# Создание TUN устройства
RUN mkdir -p /dev/net && \
    mknod /dev/net/tun c 10 200 && \
    chmod 0666 /dev/net/tun

# Проброс портов
EXPOSE 80/tcp
EXPOSE 69/udp
EXPOSE 41641/udp

CMD ["/setup.sh"]
