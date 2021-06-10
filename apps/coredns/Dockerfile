FROM docker.io/golang:1.16.4 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

ENV CGO_ENABLED=0 \
    GOPATH=/go \
    GOBIN=/go/bin \
    GO111MODULE=on

COPY ./apps/coredns/plugin.cfg /plugin.cfg

WORKDIR /go/src/coredns

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL4006
RUN \
  export GOOS \
  && GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) \
  && export GOARCH \
  && GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && export GOARM \
  && GOARM=$(echo ${TARGETPLATFORM} | cut -d / -f3 | cut -c2-) \
  && git clone https://github.com/coredns/coredns.git . \
  && git checkout v${VERSION} \
  && mv /plugin.cfg . \
  && go get github.com/openshift/coredns-mdns \
  && go get github.com/coredns/alternate \
  && go get github.com/jwhited/wgsd \
  && go get github.com/miekg/coredns-git \
  && go get github.com/ori-edge/k8s_gateway \
  && go generate \
  && go mod tidy \
  && go build -ldflags "-s -w -X github.com/coredns/coredns/coremain.GitCommit=$(git describe --dirty --always)" -o coredns

# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

LABEL org.opencontainers.image.title="CoreDNS"
LABEL org.opencontainers.image.authors="Anthony Rabbito <hello@anthonyrabbito.com>"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL coredns-external-plugins="alternate, mdns, wgsd, coredns-git, k8s_gateway"

ARG VERSION
ARG TARGETPLATFORM

USER root

COPY --from=builder /go/src/coredns/coredns /app/coredns

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  apt-get -qq update \
  && apt-get -qq install -y \
    ca-certificates \
    tzdata \
    curl \
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

EXPOSE 53 53/udp

CMD ["/app/coredns", "-conf", "/config/Corefile"]
