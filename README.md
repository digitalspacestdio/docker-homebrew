# Homebrew docker images
Docker
### Build for the latest Homebrew release 
Fedora
```bash
GIT_REMOTE="https://github.com/Homebrew/brew"
GIT_REF=$(curl -s https://api.github.com/repos/Homebrew/brew/tags | grep '"name":' | awk -F '"' '{print $4}' | head -n 1)

docker build \
--build-arg HOMEBREW_BREW_GIT_REMOTE="${GIT_REMOTE}" \
--build-arg HOMEBREW_BREW_GIT_REF="${GIT_REF}" \
-t homebrew:${GIT_REF}-fedora \
-f fedora/Dockerfile .
```

Debian
```bash
GIT_REMOTE="https://github.com/Homebrew/brew"
GIT_REF=$(curl -s https://api.github.com/repos/Homebrew/brew/tags | grep '"name":' | awk -F '"' '{print $4}' | head -n 1)

docker build \
--build-arg HOMEBREW_BREW_GIT_REMOTE="${GIT_REMOTE}" \
--build-arg HOMEBREW_BREW_GIT_REF="${GIT_REF}" \
-t homebrew:${GIT_REF}-debian \
-f debian/Dockerfile .
```

Alpine
```bash
GIT_REMOTE="https://github.com/Homebrew/brew"
GIT_REF=$(curl -s https://api.github.com/repos/Homebrew/brew/tags | grep '"name":' | awk -F '"' '{print $4}' | head -n 1)

docker build \
--build-arg HOMEBREW_BREW_GIT_REMOTE="${GIT_REMOTE}" \
--build-arg HOMEBREW_BREW_GIT_REF="${GIT_REF}" \
-t homebrew:${GIT_REF}-alpine \
-f alpine/Dockerfile .
```

## Local Machine
```bash
# Install Requirements
curl -s https://raw.githubusercontent.com/digitalspacestdio/docker-homebrew/main/install-requirements.sh | sudo sh

# Install Ruby
curl -s https://raw.githubusercontent.com/digitalspacestdio/docker-homebrew/main/install-ruby.sh | sudo sh

# Install Homebrew
curl -s https://raw.githubusercontent.com/digitalspacestdio/docker-homebrew/main/install-homebrew.sh | sudo sh
```