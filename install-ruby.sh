#!/bin/sh
set -eux;
cd /tmp;

RUBY_MAJOR=${RUBY_MAJOR:-"3.3"}
RUBY_VERSION=${RUBY_VERSION:-"3.3.3"}
#RUBY_DOWNLOAD_SHA256=${RUBY_DOWNLOAD_SHA256:-"83c0995388399c9555bad87e70af069755b5a9d84bbaa74aa22d1e37ff70fc1e"}

[ -d /opt/ruby/${RUBY_VERSION} ] || { \
    curl -o ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.xz"; \
    #echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c -; \
    \
    mkdir -p /usr/src/ruby; \
    tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
    cd /usr/src/ruby; \
    \
    # hack in "ENABLE_PATH_CHECK" disabling to suppress:
    #   warning: Insecure world writable dir
    { \
        echo '#define ENABLE_PATH_CHECK 0'; \
        echo; \
        cat file.c; \
    } > file.c.new; \
    mv file.c.new file.c; \
    \
    autoconf; \
    arch="$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')"; \
    ./configure \
        --prefix="/opt/ruby/${RUBY_VERSION}" \
        --build="$arch" \
        --disable-install-doc \
        --enable-shared; \
    \
    make -j "$(nproc)"; \
    make install; \
}; \
ln -s -f /opt/ruby/${RUBY_VERSION}/bin/* /usr/local/bin/;