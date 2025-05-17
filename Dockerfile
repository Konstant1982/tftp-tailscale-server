FROM alpine:latest

RUN apk add --no-cache \
    nginx \
    tailscale \
    busybox \
    wget  # Добавляем wget вместо curl

COPY setup.sh /setup.sh
RUN chmod +x /setup.sh

EXPOSE 80/tcp
EXPOSE 69/udp
EXPOSE 41641/udp

CMD ["/setup.sh"]
