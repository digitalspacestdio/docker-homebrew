ARG BASE_IMAGE_REPO=debian
ARG BASE_IMAGE_TAG=bookworm-slim

FROM ${BASE_IMAGE_REPO}:${BASE_IMAGE_TAG} AS base

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

COPY debian/01_nodoc /etc/dpkg/dpkg.conf.d/01_nodoc
COPY debian/ftp.debian.org.list /etc/apt/sources.list.d/ftp.debian.org.list 
COPY --chmod=0755 install-requirements.sh /install-requirements.sh

RUN set -eux; \
    \
    /install-requirements.sh; \
    \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen; \
    dpkg-reconfigure locales; \
    update-locale LANG=en_US.UTF-8; \
    apt-get clean; \
  	rm -rf /var/cache/*; \
    rm -rf /var/lib/apt/lists/*;
    
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

# Install Homebrew
COPY --chmod=0755 install-homebrew.sh /install-homebrew.sh
RUN /install-homebrew.sh

# Install homebrew curl
RUN set -eux; \
    brew install curl; \
    # Remove cache
    rm -rf /home/linuxbrew/.cache/*;
