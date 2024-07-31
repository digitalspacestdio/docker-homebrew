ARG BASE_IMAGE_REPO=debian
ARG BASE_IMAGE_TAG=bookworm-slim

FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_TAG} AS base

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

COPY 01_nodoc /etc/dpkg/dpkg.conf.d/01_nodoc
COPY ftp.debian.org.list /etc/apt/sources.list.d/ftp.debian.org.list

RUN set -eux; \
    apt update;\
    apt install -yqq \
        locales \
        ca-certificates \
        curl \
        git \
        patch \
        perl \
        systemtap-sdt-dev \
        build-essential \
        clang \
        autoconf \
        libffi-dev \
        libgmp-dev \
        libssl-dev \
        libyaml-dev \        
        zlib1g-dev; \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen; \
    dpkg-reconfigure locales; \
    update-locale LANG=en_US.UTF-8; \
    apt-get clean; \
  	rm -rf /var/cache/*; \
    rm -rf /var/lib/apt/lists/*; \
    \
    useradd -m -s /bin/bash linuxbrew

SHELL ["/bin/bash", "-c"]

FROM base AS ruby

ARG RUBY_MAJOR="3.3"
ARG RUBY_VERSION="3.3.3"
ARG RUBY_DOWNLOAD_SHA256="83c0995388399c9555bad87e70af069755b5a9d84bbaa74aa22d1e37ff70fc1e"

RUN set -eux; \
    cd /tmp; \
    curl -o ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR}/ruby-${RUBY_VERSION}.tar.xz"; \
    echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c -; \
    \
    mkdir -p /usr/src/ruby; \
    tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; \
    rm ruby.tar.xz;  \
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
        --prefix="/opt/ruby" \
        --build="$arch" \
        --disable-install-doc \
        --enable-shared; \
    \
    make -j "$(nproc)"; \
    make install;

FROM base AS linuxbrew
USER root

COPY --from=ruby /opt/ruby /opt/ruby
RUN set -eux; \
    ln -s /opt/ruby/bin/* /usr/local/bin/;

ARG HOMEBREW_BREW_GIT_REMOTE="https://github.com/Homebrew/brew"
ARG HOMEBREW_BREW_GIT_REF="4.3.12"

USER linuxbrew

# Configure homebrew env
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    LANG=en_US.UTF-8 \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_BOTTLE_SOURCE_FALLBACK=1 \
    HOMEBREW_DEVELOPER=1 \
    HOMEBREW_BREW_GIT_REMOTE="${HOMEBREW_BREW_GIT_REMOTE}"

# Install homebrew
RUN set -eux; \
    git clone --branch ${HOMEBREW_BREW_GIT_REF} --single-branch --depth 1 ${HOMEBREW_BREW_GIT_REMOTE} /home/linuxbrew/.linuxbrew/Homebrew; \
    mkdir -p \
        /home/linuxbrew/.linuxbrew/etc \
        /home/linuxbrew/.linuxbrew/include \
        /home/linuxbrew/.linuxbrew/lib \
        /home/linuxbrew/.linuxbrew/opt \
        /home/linuxbrew/.linuxbrew/sbin \
        /home/linuxbrew/.linuxbrew/share \
        /home/linuxbrew/.linuxbrew/var/homebrew/linked \
        /home/linuxbrew/.linuxbrew/Cellar \
        /home/linuxbrew/.linuxbrew/bin \
        /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/; \
    ln -s ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/;

# Install homebrew core tap with patches
RUN set -eux; \
    git clone --depth=1 https://github.com/homebrew/homebrew-core.git /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core; \
    cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core; \
    patch -p1 < <(curl -sL https://github.com/Homebrew/homebrew-core/commit/bba589dda0ad24f8bf0a24e71185ed6af2514616.diff);

# Install fastfetch
RUN set -eux; \
    brew install fastfetch; \
    rm -rf /home/linuxbrew/.cache/*

FROM base
USER root

COPY --from=ruby /opt/ruby /opt/ruby
RUN set -eux; \
    ln -s /opt/ruby/bin/* /usr/local/bin/;

COPY --from=linuxbrew --chown=linuxbrew:linuxbrew /home/linuxbrew/.linuxbrew/ /home/linuxbrew/.linuxbrew/

# Configure homebrew env
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    LANG=en_US.UTF-8 \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_BOTTLE_SOURCE_FALLBACK=1 \
    HOMEBREW_DEVELOPER=1

# Configure ruby env
ENV GEM_HOME=/usr/local/bundle \
    BUNDLE_SILENCE_ROOT_WARNING=1

ENV BUNDLE_APP_CONFIG="$GEM_HOME" \
    PATH=$GEM_HOME/bin:$PATH

# adjust permissions of a few directories for running "gem install" as an arbitrary user
RUN mkdir -p "$GEM_HOME" && chmod 0777 "$GEM_HOME"

RUN set -eux; \
    mkdir -p /usr/local/etc; \
    { \
        echo 'install: --no-document'; \
        echo 'update: --no-document'; \
    } >> /usr/local/etc/gemrc

USER linuxbrew
WORKDIR /home/linuxbrew