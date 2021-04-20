FROM golang:1.16 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV CGO_ENABLED=0 \
    GOPATH=/go \
    GOBIN=/go/bin \
    GO111MODULE=off

WORKDIR /go/src/xteve

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
  export GOOS \
  && GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) \
  && export GOARCH \
  && GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && export GOARM \
  && GOARM=$(echo ${TARGETPLATFORM} | cut -d / -f3 | cut -c2-) \
  && git clone https://github.com/xteve-project/xTeVe.git . \
  && git checkout ${VERSION} \
  && go get github.com/koron/go-ssdp \
  && go get github.com/gorilla/websocket \
  && go get github.com/kardianos/osext \
  && go build -o /xteve xteve.go

# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION
ARG TARGETPLATFORM

USER root

COPY --from=builder /xteve /app/xteve

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  apt-get -qq update \
  && apt-get -qq install -y \
    ca-certificates \
    tzdata \
    ffmpeg \
    curl \
    vlc \
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
  && chown -R kah:kah /app \
  && chmod -R u=rwX,go=rX /app \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 34400

COPY ./apps/xteve/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
