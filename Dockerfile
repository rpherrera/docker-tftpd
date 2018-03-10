FROM alpine:3.7

LABEL maintainer='Rafael de Paula Herrera <herrera.rp@gmail.com>'

RUN apk update && \
    apk add tftp-hpa=5.2-r2 && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* &&\
    mkdir -p /tftpboot

VOLUME /tftpboot

EXPOSE 69/udp

ENTRYPOINT ["/usr/sbin/in.tftpd"]
CMD ["--foreground", "--secure", "--verbose", "/tftpboot"]