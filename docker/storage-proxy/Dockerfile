FROM alpine:3.9

RUN apk update && apk upgrade \
&&  rm -rf /var/cache/apk/*

RUN apk add --no-cache openssh

ADD bin /usr/local/bin
RUN chmod 755 /usr/local/bin/*

EXPOSE 22

ENTRYPOINT [ "/bin/sh", "-c" ]
CMD [ "start-sshd" ]
