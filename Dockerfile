FROM alpine:3.2

RUN apk add --update samba=4.2.1-r2 && \
    rm -rf /var/cache/apk/*

EXPOSE 139
EXPOSE 445

ADD samba.sh /

ENTRYPOINT ["/samba.sh"]
