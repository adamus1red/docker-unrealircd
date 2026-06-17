ARG PKG="wget gcc make binutils libc6-compat g++ openssl-dev openssl curl curl-dev gnupg"
ARG VER="6.2.5"
ARG UID=10000

FROM alpine:3.24.1
ARG PKG
ARG VER
ARG UID

COPY ./config.settings /tmp/config.settings

WORKDIR /usr/src/ircd
RUN set -x \
    && apk add --no-cache --virtual build ${PKG} && apk add --no-cache libcurl \
    && wget -O /tmp/unrealircd.tar.gz https://www.unrealircd.org/downloads/unrealircd-${VER}.tar.gz \
    && wget -O /tmp/unrealircd.tar.gz.asc https://www.unrealircd.org/downloads/unrealircd-${VER}.tar.gz.asc \
    && wget -O /tmp/unrealircd.keys https://raw.githubusercontent.com/unrealircd/unrealircd/unreal60_dev/doc/KEYS \
    && gpg --import /tmp/unrealircd.keys \
    && gpg --verify --keyring /tmp/unrealircd.keys /tmp/unrealircd.tar.gz.asc \
    && tar xvfz /tmp/unrealircd.tar.gz \
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
CMD ["/app/unrealircd/unrealircd start" ]
