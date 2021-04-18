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
  MICRO_CONFIG_HOME=/tmp

RUN \
  adduser kah \
  --uid 568 \
  --group \
  --system \
  --disabled-password \
  --no-create-home \
  && \
  mkdir -p /config \
  && chown -R kah:kah /config \
  && chmod -R 775 /config

WORKDIR /app

# hadolint ignore=DL3008,DL3015
RUN \
  set -eux \
  && echo 'APT::Install-Recommends "false";' >/etc/apt/apt.conf.d/00recommends \
  && echo 'APT::Install-Suggests "false";' >>/etc/apt/apt.conf.d/00recommends \
  && echo 'APT::Get::Install-Recommends "false";' >>/etc/apt/apt.conf.d/00recommends \
  && echo 'APT::Get::Install-Suggests "false";' >>/etc/apt/apt.conf.d/00recommends \
  && \
  apt-get -qq update \
  && \
  apt-get install -y \
    bash \
    ca-certificates \
    curl \
    jq \
    locales \
    tini \
    tzdata \
  && \
  localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
  && \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') export MICRO_ARCH='linux64' ;; \
    'linux/arm64') export MICRO_ARCH='linux-arm64' ;; \
    'linux/arm/v7') export MICRO_ARCH='linux-arm' ;; \
  esac \
  && MICRO_VERSION=$(curl -s "https://api.github.com/repos/zyedidia/micro/releases" | jq --raw-output '.[0].tag_name') \
  && MICRO_VERSION="${MICRO_VERSION#?}" \
  && curl -fsSL "https://github.com/zyedidia/micro/releases/download/v${MICRO_VERSION}/micro-${MICRO_VERSION}-${MICRO_ARCH}.tar.gz" | tar xzf - -C /tmp --strip-components=1 \
  && mv /tmp/micro /usr/local/bin/micro \
  && ln -s /usr/local/bin/micro /usr/local/bin/vi \
  && ln -s /usr/local/bin/micro /usr/local/bin/vim \
  && ln -s /usr/local/bin/micro /usr/local/bin/nano \
  && ln -s /usr/local/bin/micro /usr/local/bin/emacs \
  && unset MICRO_ARCH \
  && unset MICRO_VERSION \
  && chown -R kah:kah /app \
  && \
  printf "/bin/bash /shim/greeting.sh\n" >> /etc/bash.bashrc \
  && \
  apt-get remove -y jq \
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

ENV LANG en_US.UTF-8

USER kah

VOLUME [ "/config" ]

COPY ./base/ubuntu/shim /shim
ENTRYPOINT [ "/usr/bin/tini", "--" ]

LABEL "maintainer"="Devin Buhl <devin.kray@gmail.com>, Bernd Schorgers <me@bjw-s.dev>"
LABEL "org.opencontainers.image.source"="https://github.com/k8s-at-home/container-images"
