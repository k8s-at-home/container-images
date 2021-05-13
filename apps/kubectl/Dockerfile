# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest as base
# hadolint ignore=DL3002
USER root
ARG TARGETARCH
ARG VERSION
WORKDIR /tmp
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN \
  apt-get -qq update \
  && apt-get -qq install -y --no-install-recommends \
    wget \
  && wget -nv "https://dl.k8s.io/release/v${VERSION}/bin/linux/${TARGETARCH}/kubectl" \
  && chmod +x kubectl

# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest
WORKDIR /app
USER root
# hadolint ignore=DL3008
RUN \
  apt-get -qq update \
  && apt-get -qq install -y --no-install-recommends \
    jq \
    curl \
  && chown -R kah:kah /app \
  && chmod -R u=rwX,go=rX /app \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/ \
    /var/tmp/*
COPY --chown=kah:kah --from=base /tmp/kubectl ./kubectl
USER kah
CMD [ "./kubectl" ]
