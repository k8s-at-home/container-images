# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION
ARG TARGETPLATFORM
USER root

WORKDIR /app

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    git \
    openssl \
  && \
   case "${TARGETPLATFORM}" in \
    'linux/amd64') export ARCH='amd64' ;; \
    'linux/arm64') export ARCH='arm64' ;; \
    'linux/arm/v7') export ARCH='arm' ;; \
  esac \
  && echo "$ARCH" \
  && curl -fsSL -o reg \
    "https://github.com/genuinetools/reg/releases/download/v${VERSION}/reg-linux-${ARCH}" \
  && chmod +x reg \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && update-ca-certificates

USER kah

WORKDIR /config

COPY ./apps/reg/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["--help"]
