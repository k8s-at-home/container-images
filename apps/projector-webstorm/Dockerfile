# Build final container
FROM ghcr.io/k8s-at-home/projector:latest

ARG VERSION

USER root

WORKDIR /app/ide

RUN \
  set -o pipefail \
  && curl -fsSL "https://download.jetbrains.com/webstorm/WebStorm-${VERSION}.tar.gz" | tar -xz --strip-components 1

WORKDIR /config

RUN \
     chmod -R u=rwX,go=rX /app /data \
  && chown -R kah:kah /app /data

USER kah
