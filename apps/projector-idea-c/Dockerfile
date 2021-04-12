# Build final container
FROM ghcr.io/k8s-at-home/projector:latest

ARG VERSION

USER root

WORKDIR /app/ide

RUN \
     curl -fsSL "https://download.jetbrains.com/idea/ideaIC-${VERSION}.tar.gz" | tar -xz --strip-components 1 \
  && chmod -R u=rwX,go=rX /app \
  && chown -R kah:kah /app

WORKDIR /config

USER kah
