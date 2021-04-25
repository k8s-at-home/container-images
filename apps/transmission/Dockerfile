# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

# hadolint ignore=DL3002
USER root

WORKDIR /tmp

# Install system dependencies
# hadolint ignore=DL3008
RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    cmake \
    git \
    intltool \
    libappindicator3-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libglib2.0-dev \
    libminiupnpc-dev \
    libssh-dev \
    libtool \
    pkg-config \
    software-properties-common \
    gpg \
    dirmngr

# Install golang and envsubst
# hadolint ignore=DL3008
RUN \
  add-apt-repository ppa:longsleep/golang-backports \
  && apt-get update \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 52B59B1571A79DBC054901C0F6BC817356A3D45E \
  && apt-get install -y --no-install-recommends \
    golang-1.16 \
  && export GOPATH=/go \
  && export PATH=$PATH:/go/bin \
  && /usr/lib/go-1.16/bin/go get github.com/a8m/envsubst/cmd/envsubst

WORKDIR /tmp/transmission

# Compile transmission
RUN \
  git clone --depth 1 -b ${VERSION} https://github.com/transmission/transmission.git . \
  && git submodule update --init \
  && ./autogen.sh --without-gtk \
  && make -s \
  && make install

# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG TARGETPLATFORM
ARG VERSION

# Proper way to set config directory
ENV HOME=/config \
    XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/config \
    WEBUI_PORT=9091 \
    TRANSMISSION_WEB_HOME=/web

USER root

COPY --from=builder /usr/local/bin/transmission-daemon /app/transmission-daemon
COPY --from=builder /usr/local/share/transmission/web /web
COPY --from=builder /go/bin/envsubst /usr/local/bin/envsubst

# hadolint ignore=DL3008,DL3015
RUN \
  apt-get -qq update \
  && \
  apt-get install -y \
    libevent-dev \
    libminiupnpc-dev \
    p7zip-full \
    python3 \
    rsync \
    unrar \
    unzip \
  && \
  apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chown -R kah:kah /app \
  && chown -R kah:kah /web \
  && chmod -R u=rwX,go=rX /app \
  && chmod -R u=rwX,go=rX /web \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE ${WEBUI_PORT} 51413

COPY ./apps/transmission/settings.json.tmpl /app/settings.json.tmpl
COPY ./apps/transmission/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
