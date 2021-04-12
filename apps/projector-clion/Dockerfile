# Download IDE
FROM ghcr.io/k8s-at-home/projector:latest AS ide

ARG IDE_DOWNLOAD_URL
USER root
WORKDIR /download

RUN curl -fsSL $IDE_DOWNLOAD_URL | tar -xz --strip-components 1

# Build final container
FROM ghcr.io/k8s-at-home/projector:latest

ARG IDE_DOWNLOAD_URL
USER root
WORKDIR /app

# copy IDE
COPY --from=ide /download /app/ide

WORKDIR /config

RUN \
     apt-get -qq update \
  && apt-get -qq -y install build-essential clang \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app  \
  && chown -R kah:kah /app

USER kah
