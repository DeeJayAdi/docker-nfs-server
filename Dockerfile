FROM ubuntu

RUN apt update && apt upgrade -y
RUN apt install -y nfs-kernel-server

EXPOSE 111 2049 20048

ENTRYPOINT [ "bash" ]