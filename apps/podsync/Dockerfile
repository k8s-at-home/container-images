FROM golang:1.16 as builder

ENV CGO_ENABLED=0 \
    GOPATH=/go \
    GOBIN=/go/bin \
    GO111MODULE=on

WORKDIR /workspace

ARG TARGETPLATFORM
ARG VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  export GOOS \
  && GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) \
  && export GOARCH \
  && GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && export GOARM \
  && GOARM=$(echo ${TARGETPLATFORM} | cut -d / -f3 | cut -c2-) \
  && git clone https://github.com/mxpv/podsync.git . \
  && git checkout ${VERSION} \
  && go build -o /bin/podsync ./cmd/podsync


# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest


# hadolint ignore=DL3002
USER root

WORKDIR /app

COPY --from=builder /bin/podsync .

# Install system dependencies
# Instal always latest version of youtube-dl via pip
# hadolint ignore=DL3008,DL3013
RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    tzdata \
    ffmpeg \
    python3-pip \
  && \
  ln -s /usr/bin/python3 /usr/bin/python \
  && \
  printf "UpdateMethod=docker\nPackageVersion=%s\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" "${VERSION}" > /app/package_info \
  && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates \
  && pip3 install --no-cache-dir youtube-dl

USER kah

EXPOSE 8080

COPY ./apps/podsync/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
