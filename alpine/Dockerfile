ARG BASE_IMAGE_REPO=alpine
ARG BASE_IMAGE_TAG=3.20

FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_TAG} AS base

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN set -eux; \
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
    rm *.apk; \
    \
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8;

SHELL ["/bin/bash", "-c"]

FROM base AS ruby

ARG RUBY_MAJOR="3.3"
ARG RUBY_VERSION="3.3.3"
ARG RUBY_DOWNLOAD_SHA256="83c0995388399c9555bad87e70af069755b5a9d84bbaa74aa22d1e37ff70fc1e"

COPY --chmod=0755 install-ruby.sh /install-ruby.sh
RUN /install-ruby.sh

FROM base

ARG RUBY_VERSION="3.3.3"

# Configure ruby env
ENV GEM_HOME=/usr/local/bundle \
    BUNDLE_SILENCE_ROOT_WARNING=1

ENV BUNDLE_APP_CONFIG="$GEM_HOME" \
    PATH=$GEM_HOME/bin:$PATH

COPY --from=ruby "/opt/ruby/${RUBY_VERSION}" "/opt/ruby/${RUBY_VERSION}"

RUN ln -s /opt/ruby/${RUBY_VERSION}/bin/* /usr/local/bin/;

# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 0777 "$GEM_HOME"; \
    mkdir -p /usr/local/etc; \
    { \
        echo 'install: --no-document'; \
        echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc

# Install homebrew
ARG HOMEBREW_BREW_GIT_REMOTE
ARG HOMEBREW_BREW_GIT_REF

# Add linuxbrew user
RUN useradd -m -s /bin/bash linuxbrew
WORKDIR /home/linuxbrew

# Homebrew env
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_NO_INSTALL_FROM_API=1 \
    HOMEBREW_NO_ENV_HINTS=1 \
    HOMEBREW_BOTTLE_SOURCE_FALLBACK=1 \
    HOMEBREW_DEVELOPER=1

USER linuxbrew

COPY --chmod=0755 install-homebrew.sh /install-homebrew.sh
RUN /install-homebrew.sh

# Install homebrew curl
RUN set -eux; \
    brew install curl; \
    # Remove cache
    rm -rf /home/linuxbrew/.cache/*;