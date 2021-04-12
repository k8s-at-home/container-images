# Download projector-server
# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest AS projector

ARG VERSION

# hadolint ignore=DL3002
USER root

WORKDIR /download

# hadolint ignore=DL3008,DL3015
RUN \
  apt-get -qq update \
  && apt-get install -y jq unzip \
  && curl -fsSL -o ps.zip "https://github.com/JetBrains/projector-server/releases/download/v${VERSION}/projector-server-v${VERSION}.zip" \
  && unzip ps.zip \
  && mv projector-server-1.0-SNAPSHOT/* . \
  && rm -r ps.zip projector-server-1.0-SNAPSHOT

# Build final container
FROM ghcr.io/k8s-at-home/ubuntu:vfocal-20210401

USER root
WORKDIR /app

# copy projector-server
COPY --from=projector /download /app/projector-server

# hadolint ignore=DL3008,DL3015
RUN \
     apt-get -qq update \
  && apt-get -qq -y install \
       # packages for awt
       libxext6 \
       libxrender1 \
       libxtst6 \
       libxi6 \
       libfreetype6 \
       # packages for user convenience
       git \
       bash-completion \
       # packages for IDEA (to disable warnings)
       procps \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && chown -R kah:kah /app \
  && usermod -d /config kah \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 8887

COPY ./base/projector/shim /shim

COPY ./base/projector/entrypoint.sh /entrypoint.sh

COPY ./base/projector/idea.properties /tmp/idea.properties

CMD ["/entrypoint.sh"]
