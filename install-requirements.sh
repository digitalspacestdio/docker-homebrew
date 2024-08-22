#!/bin/sh
set -eux
. /etc/os-release
DISTRO=${ID_LIKE:-$ID}
if [ "debian" == $DISTRO ]; then
    apt update;
    apt install -yqq \
        locales \
        ca-certificates \
        curl \
        git \
        patch \
        bzip2 \
        perl \
        systemtap-sdt-dev \
        build-essential \
        clang \
        autoconf \
        libffi-dev \
        libgmp-dev \
        libssl-dev \
        libyaml-dev \
        zlib1g-dev;
elif [ "fedora" == $DISTRO ]; then
    dnf groupinstall -y "Development Tools" "Development Libraries";\
    dnf install -y \
        glibc-locale-source \
        ca-certificates \
        curl \
        git \
        patch \
        perl \
        systemtap-sdt-devel \
        bzip2 \
        clang;
elif [ "alpine" == $DISTRO ]; then
    echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories; \
    apk add --no-cache \
        shadow \
        bash \
        curl \
        git \
        patch \
        bzip2 \
        perl \
        gcc \
        make \
        clang \
        autoconf \
        libstdc++ \
        libffi-dev \
        gmp-dev \
        openssl-dev \
        yaml-dev \
        zlib-dev; \
    \
    curl -L -o /etc/apk/keys/sgerrand.rsa.pub https://github.com/sgerrand/alpine-pkg-glibc/releases/download/sgerrand.rsa.pub; \
    curl -L -o glibc-2.34-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-2.34-r0.apk; \
    curl -L -o glibc-bin-2.34-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-bin-2.34-r0.apk; \
    curl -L -o glibc-i18n-2.34-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.34-r0/glibc-i18n-2.34-r0.apk; \
    apk add --force-overwrite --allow-untrusted \
        glibc-2.34-r0.apk \
        glibc-bin-2.34-r0.apk \
        glibc-i18n-2.34-r0.apk; \
    rm *.apk;
else
    echo "Unsupported distro: $DISTRO"
    exit 1
fi
