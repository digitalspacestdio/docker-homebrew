#!/bin/sh
set -eux

if [ $UID -eq 0 ]; then
  echo ""
  echo "------------------------------------"
  echo "This script must NOT be run as ROOT"
  echo "------------------------------------"
  echo ""
  exit 1
fi

export HOMEBREW_PREFIX=${HOMEBREW_PREFIX:-"/home/linuxbrew/.linuxbrew"}

# Install Requirements
curl -s https://raw.githubusercontent.com/digitalspacestdio/docker-homebrew/main/install-requirements.sh | sudo sh

# Install Ruby
curl -s https://raw.githubusercontent.com/digitalspacestdio/docker-homebrew/main/install-ruby.sh | sudo sh

# Install Homebrew
curl -s https://raw.githubusercontent.com/digitalspacestdio/docker-homebrew/main/install-homebrew.sh | sudo sh

sudo chown -R ${USER} ${HOMEBREW_PREFIX}

BREW_BIN=${HOMEBREW_PREFIX}/bin/brew

[ -f "${BREW_BIN}" ] && {
    [ -f "$HOME/.zprofile" ] && {
        grep 'eval "$('${BREW_BIN}' shellenv)"' "$HOME/.zprofile" || {
            echo 'eval "$('${BREW_BIN}' shellenv)"') | tee -a $HOME/.zprofile
        }
    }

    [ -f "$HOME/.bashrc" ] && {
        grep 'eval "$('${BREW_BIN}' shellenv)"' "$HOME/.bashrc" || {
            echo 'eval "$('${BREW_BIN}' shellenv)"') | tee -a $HOME/.bashrc
        }
    }
}