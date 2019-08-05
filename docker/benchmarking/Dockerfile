FROM alpine:3.9

RUN apk update && apk upgrade \
&&  rm -rf /var/cache/apk/*

RUN apk add --no-cache \
    curl \
    tar

WORKDIR /tmp
RUN curl -L https://www.coker.com.au/bonnie++/bonnie++-1.98.tgz | tar -xz

RUN apk --no-cache add \
    make \
    alpine-sdk \
    zlib-dev \
    libaio-dev \
    linux-headers \
    coreutils \
    libaio && \
    git clone https://github.com/axboe/fio && \
    cd fio && \
    ./configure && \
    make -j`nproc` && \
    make install && \
    cd .. && \
    rm -rf fio && \
    apk --no-cache del \
    make \
    alpine-sdk \
    zlib-dev \
    libaio-dev \
    linux-headers \
    coreutils

VOLUME /tmp
WORKDIR /tmp
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["fio"]
