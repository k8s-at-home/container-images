# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest
USER root
ARG TARGETARCH
ARG VERSION
# hadolint ignore=DL3008
RUN \
  apt-get -qq update \
  && apt-get -qq install -y --no-install-recommends \
    jq \
  && curl -fsSL -o kubectl "https://dl.k8s.io/release/v${VERSION}/bin/linux/${TARGETARCH}/kubectl" \
  && chmod +x kubectl \
  && chmod -R u=rwX,go=rX /app \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/ \
    /var/tmp/*
USER kah
CMD [ "./kubectl" ]
