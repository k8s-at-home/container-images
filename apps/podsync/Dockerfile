FROM golang:1.16.3-buster AS builder
# PODSYNC_VERSION can be changed, by passing `--build-arg PODSYNC_VERSION=<new version>` during docker build
ARG PODSYNC_VERSION=v2.4.0
ENV PODSYNC_VERSION=${PODSYNC_VERSION}
LABEL stage=builder
WORKDIR /workspace
#hadolint ignore=DL4006
RUN wget -O - https://github.com/mxpv/podsync/archive/refs/tags/${PODSYNC_VERSION}.tar.gz | tar -xz --strip-components=1
RUN go build -o /bin/podsync ./cmd/podsync


# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG TARGETPLATFORM
ARG VERSION

# hadolint ignore=DL3002
USER root

WORKDIR /app

# Install system dependencies
# hadolint ignore=DL3008
RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    tzdata \
    youtube-dl

COPY --from=builder /bin/podsync .

RUN printf "UpdateMethod=docker\nPackageVersion=%s\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" "${VERSION}" > /app/package_info

RUN \
  chmod -R u=rwX,go=rX /app \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 8080

COPY ./apps/podsync/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
