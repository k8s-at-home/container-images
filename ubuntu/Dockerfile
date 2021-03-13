ARG VERSION

FROM ubuntu:${VERSION}

ARG TARGETPLATFORM

ENV \
  DEBCONF_NONINTERACTIVE_SEEN=true \
  DEBIAN_FRONTEND=noninteractive \
  TINI_VERSION=0.19.0 \
  UMASK=0002

RUN \
  adduser kah \
  --uid 568 \
  --group \
  --system \
  --disabled-password \
  --no-create-home \
  && \
  mkdir -p /config \
  && chown -R kah:kah /config

WORKDIR /app

RUN \
  set -eux \
  && \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') export ARCH='amd64' ;; \
    'linux/arm64') export ARCH='arm64' ;; \
    'linux/arm/v7') export ARCH='armhf' ;; \
  esac \
  && \
  echo 'APT::Install-Recommends "false";' >/etc/apt/apt.conf.d/00recommends \
  && echo 'APT::Install-Suggests "false";' >>/etc/apt/apt.conf.d/00recommends \
  && echo 'APT::Get::Install-Recommends "false";' >>/etc/apt/apt.conf.d/00recommends \
  && echo 'APT::Get::Install-Suggests "false";' >>/etc/apt/apt.conf.d/00recommends \
  && \
  apt-get -qq update \
  && \
  apt-get -qq install -y --no-install-recommends --no-install-suggests \
    ca-certificates \
    curl \
    gnupg2 \
    locales \
    tzdata \
    vim \
  && locale-gen en_US.UTF-8 \
  && curl -fsSL -o /sbin/tini "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${ARCH}" \
  && curl -fsSL -o /tini.asc "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-${ARCH}.asc" \
  && gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
  && gpg --batch --verify /tini.asc /sbin/tini \
  && chmod +x /sbin/tini \
  && gpgconf --kill all \
  && \
  apt-get remove -y \
    gnupg2 \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tini.asc \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/tmp/*

USER kah

VOLUME [ "/config" ]

COPY ./shim /shim
ENTRYPOINT [ "/sbin/tini", "--" ]

LABEL "maintainer"="Devin Buhl <devin.kray@gmail.com>, Bernd Schorgers <me@bjw-s.dev>"
LABEL "org.opencontainers.image.source"="https://github.com/k8s-at-home/container-images"
