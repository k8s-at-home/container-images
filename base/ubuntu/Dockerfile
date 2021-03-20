ARG VERSION

FROM ubuntu:${VERSION}

ARG TARGETPLATFORM

# DEBIAN_FRONTEND: https://askubuntu.com/questions/972516/debian-frontend-environment-variable
# APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE: http://stackoverflow.com/questions/48162574/ddg#49462622
ENV \
  DEBCONF_NONINTERACTIVE_SEEN=true \
  DEBIAN_FRONTEND="noninteractive" \
  APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn \
  TINI_VERSION=0.19.0 \
  UMASK=0002 \
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8

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

# hadolint ignore=DL3008,DL3015
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
  apt-get install -y \
    ca-certificates \
    curl \
    locales \
    tini \
    tzdata \
    vim \
  && locale-gen en_US.UTF-8 \
  && update-locale \
  && dpkg-reconfigure -f noninteractive locales \
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

COPY ./base/ubuntu/shim /shim
ENTRYPOINT [ "/usr/bin/tini", "--" ]

LABEL "maintainer"="Devin Buhl <devin.kray@gmail.com>, Bernd Schorgers <me@bjw-s.dev>"
LABEL "org.opencontainers.image.source"="https://github.com/k8s-at-home/container-images"
