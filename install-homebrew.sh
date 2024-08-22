#!/bin/sh
set -eux;
cd /tmp;

HOMEBREW_BREW_GIT_REMOTE=${HOMEBREW_BREW_GIT_REMOTE:-"https://github.com/Homebrew/brew"}
HOMEBREW_BREW_GIT_REF=${HOMEBREW_BREW_GIT_REF:-$(curl -s https://api.github.com/repos/$(echo ${HOMEBREW_BREW_GIT_REMOTE} | awk -F/ '{ print $4"/"$5}')/tags | grep '"name":' | awk -F '"' '{print $4}' | head -n 1)}
HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-"/home/linuxbrew/.linuxbrew"}

git clone --branch ${HOMEBREW_BREW_GIT_REF} --single-branch --depth 1 ${HOMEBREW_BREW_GIT_REMOTE} ${HOMEBREW_PREFIX}/Homebrew; \
mkdir -p \
    ${HOMEBREW_PREFIX}/etc \
    ${HOMEBREW_PREFIX}/include \
    ${HOMEBREW_PREFIX}/lib \
    ${HOMEBREW_PREFIX}/opt \
    ${HOMEBREW_PREFIX}/sbin \
    ${HOMEBREW_PREFIX}/share \
    ${HOMEBREW_PREFIX}/var/homebrew/linked \
    ${HOMEBREW_PREFIX}/Cellar \
    ${HOMEBREW_PREFIX}/bin \
    ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/; \
ln -s ../Homebrew/bin/brew ${HOMEBREW_PREFIX}/bin/; \
\
# Install homebrew core tap with patches
git clone --depth=1 https://github.com/homebrew/homebrew-core.git ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core; \
cd ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core; \
# A small patch that allows to compile the necessary tools from source
patch -p1 < <(curl -sL https://github.com/digitalspacestdio/homebrew-core/compare/master...aarch64.diff);
