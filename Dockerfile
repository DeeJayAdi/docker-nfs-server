FROM alpine:latest

RUN apk add --update --no-cache nfs-utils rpcbind openrc

RUN mkdir -p /export

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 2049 111 20048

ENTRYPOINT ["/start.sh"]