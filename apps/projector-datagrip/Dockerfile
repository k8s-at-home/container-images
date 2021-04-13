# Build final container
# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/projector:latest

ARG VERSION

USER root

WORKDIR /app/ide

# hadolint ignore=DL4006
RUN \
     curl -fsSL "https://download.jetbrains.com/datagrip/datagrip-${VERSION#*v}.tar.gz" | tar -xz --strip-components 1 \
  && chmod -R u=rwX,go=rX /app \
  && chown -R kah:kah /app

WORKDIR /config

USER kah
