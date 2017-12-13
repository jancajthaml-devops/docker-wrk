FROM alpine:latest

MAINTAINER Jan Cajthaml <jan.cajthaml@gmail.com>

ENV WRK_VERSION=4.0.2

RUN apk update
RUN apk add make gcc openssl-dev tar wget musl-dev perl git

RUN wget https://github.com/wg/wrk/archive/$WRK_VERSION.tar.gz -O - | tar -zx && \
    cd wrk-${WRK_VERSION} && \
    make && \
    cp wrk /usr/local/bin && \
    cd .. && rm -rf wrk-${WRK_VERSION}

VOLUME [ "/data" ]
WORKDIR /data

ENTRYPOINT ["/usr/local/bin/wrk"]
