# Build final container
FROM ghcr.io/k8s-at-home/projector:1.1.2

ARG VERSION

USER root

WORKDIR /app/ide

# hadolint ignore=DL4006,DL3015,DL3008
RUN \
     curl -fsSL "https://download.jetbrains.com/python/pycharm-community-${VERSION}.tar.gz" | tar -xz --strip-components 1 \
  && apt-get -qq update \
  && apt-get -qq -y install \
     python2 \
     python3 \
     python3-distutils \
     python3-pip \
     python3-setuptools \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && chown -R kah:kah /app

WORKDIR /config

USER kah
