ARG PKG="wget gcc make binutils libc6-compat g++ openssl-dev"
ARG VER="5.0.7"
ARG UID=10000

FROM alpine:3.12.0
ARG PKG
ARG VER
ARG UID

COPY ./config.settings /tmp/config.settings

WORKDIR /usr/src/ircd
RUN set -x \
    && apk add --no-cache --virtual build ${PKG} \
    && wget -O /tmp/unrealircd https://www.unrealircd.org/downloads/unrealircd-${VER}.tar.gz \
    && tar xvfz /tmp/unrealircd \
    && cd ./unrealircd-${VER}/ \
    && cp /tmp/config.settings /usr/src/ircd/unrealircd-${VER}/config.settings \
    && ./Config -quick \
    && make && make install \
    && rm -rf /usr/src/ircd \
    && apk del build \
    && RUN addgroup -S unreal && adduser -u ${UID} -S unreal -G unreal

WORKDIR /ircd
CMD ["/usr/local/bin/hopm", "-d"]
