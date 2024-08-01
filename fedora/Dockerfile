ARG BASE_IMAGE_REPO=fedora
ARG BASE_IMAGE_TAG=40

FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_TAG} AS base

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

RUN set -eux; \
    echo "tsflags=nodocs" >> /etc/dnf/dnf.conf; \
    dnf groupinstall -y "Development Tools" "Development Libraries";\
    dnf install -y \
        glibc-locale-source \
        ca-certificates \
        curl \
        git \
        patch \
        perl \
        systemtap-sdt-devel \
        clang; \
    localedef -i en_US -f UTF-8 en_US.UTF-8; \
    dnf clean all; \
  	rm -rf /var/cache/*;

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
    make install;

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
ARG HOMEBREW_BREW_GIT_REMOTE="https://github.com/Homebrew/brew"
ARG HOMEBREW_BREW_GIT_REF="4.3.12"

# Add linuxbrew user
RUN useradd -m -s /bin/bash linuxbrew
WORKDIR /home/linuxbrew

# Homebrew env
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    HOMEBREW_NO_INSTALL_FROM_API=1 \
    HOMEBREW_NO_ENV_HINTS=1 \
    HOMEBREW_BREW_GIT_REMOTE="${HOMEBREW_BREW_GIT_REMOTE}" \
    HOMEBREW_BREW_GIT_REF="${HOMEBREW_BREW_GIT_REF}" \
    HOMEBREW_BOTTLE_SOURCE_FALLBACK=1 \
    HOMEBREW_DEVELOPER=1

USER linuxbrew

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
    ln -s ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/; \
    \
    # Install homebrew core tap with patches
    git clone --depth=1 https://github.com/homebrew/homebrew-core.git /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core; \
    cd /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/homebrew/homebrew-core; \
    # A small patch that allows to compile the necessary tools from source
    patch -p1 < <(curl -sL https://github.com/digitalspacestdio/homebrew-core/compare/master...aarch64.diff);

# Install homebrew curl
RUN set -eux; \
    brew install curl; \
    # Remove cache
    rm -rf /home/linuxbrew/.cache/*;
