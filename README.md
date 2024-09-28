# Homebrew docker and local install scripts for `x86_64` and `arm64` linux hosts

## Local Machine
```bash
curl -s https://raw.githubusercontent.com/digitalspacestdio/docker-homebrew/main/install.sh | sh
```
```bash
exec $SHELL
```

### Docker
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
