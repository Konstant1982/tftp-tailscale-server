FROM alpine:latest

# Установка зависимостей
RUN apk add --no-cache \
    nginx \
    tailscale \
    busybox \
    bash

# Копируем скрипт
COPY setup.sh /setup.sh
RUN chmod +x /setup.sh

# Пробрасываем порты
EXPOSE 80/tcp
EXPOSE 69/udp
EXPOSE 41641/udp

# Запуск
CMD ["/setup.sh"]
