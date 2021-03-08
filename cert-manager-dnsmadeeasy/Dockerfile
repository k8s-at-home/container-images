FROM golang:1.15 AS build

WORKDIR /workspace
ENV GO111MODULE=on

RUN apt update -qq && apt install -qq -y git bash curl g++

# Fetch binary early because to allow more caching
COPY scripts scripts
COPY testdata testdata
RUN ./scripts/fetch-test-binaries.sh

COPY src src

# Build
RUN cd src; go mod download

RUN cd src; CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .

#Test
ARG TEST_ZONE_NAME
RUN  \
     if [ -n "$TEST_ZONE_NAME" ]; then \
       cd src; \
       CCGO_ENABLED=0 TEST_ZONE_NAME="$TEST_ZONE_NAME" go test -v .; \
     fi

FROM ghcr.io/k8s-at-home/ubuntu:latest

COPY --from=build /workspace/src/webhook /app/webhook

USER root
RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    ca-certificates \
    bash \
    curl \
  && echo "UpdateMethod=docker\nPackageVersion=${VERSION}\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" > /app/package_info \
  && apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && echo umask ${UMASK} >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah
ENTRYPOINT ["/app/webhook"]
