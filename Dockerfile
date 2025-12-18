ARG PKG="wget gcc make binutils libc6-compat g++ openssl-dev openssl curl curl-dev"
ARG VER="5.0.7"
ARG UID=10000

FROM alpine:3.23.2
ARG PKG
ARG VER
ARG UID

COPY ./config.settings /tmp/config.settings

WORKDIR /usr/src/ircd
RUN set -x \
    && apk add --no-cache --virtual build ${PKG} && apk add --no-cache libcurl \
    && wget -O /tmp/unrealircd https://www.unrealircd.org/downloads/unrealircd-${VER}.tar.gz \
    && tar xvfz /tmp/unrealircd \
    && cd ./unrealircd-${VER}/ \
    && cp /tmp/config.settings /usr/src/ircd/unrealircd-${VER}/config.settings \
    && ./Config -quick \
    && make -j$(nproc) && make install \
    && rm -rf /usr/src/ircd \
    && apk del build \
    && addgroup -S unreal && adduser -u ${UID} -S unreal -G unreal

WORKDIR /ircd
RUN set -x \
    && chown -R unreal:unreal /ircd /app
USER unreal
CMD ["/bin/sh" ]
