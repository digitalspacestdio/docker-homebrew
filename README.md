# Homebrew docker images
## Build
Fedora
```bash
docker build --build-arg HOMEBREW_BREW_GIT_REF="4.3.12" -t homebrew:fedora -f fedora/Dockerfile ./fedora
```

Debian
```bash
docker build --build-arg HOMEBREW_BREW_GIT_REF="4.3.12" -t homebrew:debian -f debian/Dockerfile ./debian
```

Alpine
```bash
docker build --build-arg HOMEBREW_BREW_GIT_REF="4.3.12" -t homebrew:alpine -f alpine/Dockerfile ./alpine
```