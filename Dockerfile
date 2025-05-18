FROM alpine:latest

# Установка зависимостей
RUN apk add --no-cache \
    nginx \
    tailscale \
    busybox \
    curl \
    tftp-hpa

# Создание непривилегированного пользователя
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY setup.sh /setup.sh

COPY fs/kernel_x86_64.efi /kernel_x86_64.efi
COPY fs/kernel_x86_64.elf /kernel_x86_64.elf

RUN chmod +x /setup.sh

EXPOSE 80/tcp
EXPOSE 69/udp
EXPOSE 41641/udp

CMD ["/setup.sh"]
