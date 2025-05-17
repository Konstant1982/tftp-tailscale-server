FROM alpine:latest

# Установка зависимостей
RUN apk add --no-cache \
    nginx \
    tailscale \
    busybox  # Убрали bash

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 80/tcp
EXPOSE 69/udp
EXPOSE 41641/udp

CMD ["/setup.sh"]
