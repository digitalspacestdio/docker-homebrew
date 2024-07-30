# Homebrew docker images
## Build
Fedora based
```bash
docker build --arg HOMEBREW_BREW_GIT_REF="4.3.12" -t homebrew:debian -f debian/Dockerfile ./debian
```

Debian based 
```bash
docker build --arg HOMEBREW_BREW_GIT_REF="4.3.12" -t homebrew:fedora -f fedora/Dockerfile ./fedora
```