FROM golang:1.16 as builder

ARG VERSION
ARG TARGETPLATFORM

ENV CGO_ENABLED=0 \
  GOPATH=/go \
  GOBIN=/go/bin

WORKDIR /tmp

RUN \
  export GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) \
  && export GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2) \
  && export GOARM=$(echo ${TARGETPLATFORM} | cut -d / -f3 | cut -c2-) \
  && curl -fsSL "https://github.com/xteve-project/xTeVe/archive/${VERSION}.tar.gz" | tar xzf - -C . --strip-components=1 \
  && go get ./... \
  && go build -o /go/bin/xteve xteve.go

FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION
ARG TARGETPLATFORM

USER root

COPY --from=builder /go/bin/xteve /app/xteve

RUN \
  apt-get -qq update \
  && apt-get -qq install -y \
    ca-certificates \
    tzdata \
    ffmpeg \
    curl \
    vlc \
  && echo "UpdateMethod=docker\nPackageVersion=${VERSION}\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" > /app/package_info \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && echo umask ${UMASK} >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 34400

COPY ./apps/xteve/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
