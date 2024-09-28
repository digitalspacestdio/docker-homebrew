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

sudo chown -R $(id -u):$(id -g) ${HOMEBREW_PREFIX}

BREW_BIN=${HOMEBREW_PREFIX}/bin/brew

[ -f "${BREW_BIN}" ] && {
    if [ -f "$HOME/.zprofile" ]; then 
        grep 'eval "$('${BREW_BIN}' shellenv)"' "$HOME/.zprofile" || {
            echo 'eval "$('${BREW_BIN}' shellenv)"' | tee -a $HOME/.zprofile
        }

        if echo $(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]') | grep aarch64; then
            mkdir -p ${HOMEBREW_PREFIX}'/.tmp'
            grep 'export HOMEBREW_TEMP='${HOMEBREW_PREFIX}'/.tmp' "$HOME/.zprofile" || {
                echo 'export HOMEBREW_TEMP='${HOMEBREW_PREFIX}'/.tmp' | tee -a $HOME/.zprofile
            }
        fi

        grep 'export HOMEBREW_NO_INSTALL_FROM_API=1' "$HOME/.zprofile" || {
            echo 'export HOMEBREW_NO_INSTALL_FROM_API=1' | tee -a $HOME/.zprofile
        }

        grep 'export HOMEBREW_NO_ENV_HINTS=1' "$HOME/.zprofile" || {
            echo 'export HOMEBREW_NO_ENV_HINTS=1' | tee -a $HOME/.zprofile
        }

        grep 'export HOMEBREW_NO_AUTO_UPDATE=1' "$HOME/.zprofile" || {
            echo 'export HOMEBREW_NO_AUTO_UPDATE=1' | tee -a $HOME/.zprofile
        }

        grep 'export HOMEBREW_DEVELOPER=1' "$HOME/.zprofile" || {
            echo 'export HOMEBREW_DEVELOPER=1' | tee -a $HOME/.zprofile
        }
    fi

    if [ -f "$HOME/.bashrc" ]; then 
        grep 'eval "$('${BREW_BIN}' shellenv)"' "$HOME/.bashrc" || {
            echo 'eval "$('${BREW_BIN}' shellenv)"' | tee -a $HOME/.bashrc
        }

        if echo $(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]') | grep aarch64; then
            mkdir -p ${HOMEBREW_PREFIX}'/.tmp'
            grep 'export HOMEBREW_TEMP='${HOMEBREW_PREFIX}'/.tmp' "$HOME/.bashrc" || {
                echo 'export HOMEBREW_TEMP='${HOMEBREW_PREFIX}'/.tmp' | tee -a $HOME/.bashrc
            }
        fi

        grep 'export HOMEBREW_NO_INSTALL_FROM_API=1' "$HOME/.bashrc" || {
            echo 'export HOMEBREW_NO_INSTALL_FROM_API=1' | tee -a $HOME/.bashrc
        }

        grep 'export HOMEBREW_NO_ENV_HINTS=1' "$HOME/.bashrc" || {
            echo 'export HOMEBREW_NO_ENV_HINTS=1' | tee -a $HOME/.bashrc
        }

        grep 'export HOMEBREW_NO_AUTO_UPDATE=1' "$HOME/.bashrc" || {
            echo 'export HOMEBREW_NO_AUTO_UPDATE=1' | tee -a $HOME/.bashrc
        }

        grep 'export HOMEBREW_DEVELOPER=1' "$HOME/.bashrc" || {
            echo 'export HOMEBREW_DEVELOPER=1' | tee -a $HOME/.bashrc
        }
    fi
}
