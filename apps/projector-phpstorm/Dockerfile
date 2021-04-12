# Build final container
FROM ghcr.io/k8s-at-home/projector:1.1.2

ARG VERSION

USER root

WORKDIR /app/ide

# hadolint ignore=DL4006
RUN \
     curl -fsSL "https://download.jetbrains.com/webide/PhpStorm-${VERSION}.tar.gz" | tar -xz --strip-components 1 \
  && chmod -R u=rwX,go=rX /app \
  && chown -R kah:kah /app

WORKDIR /config

USER kah
