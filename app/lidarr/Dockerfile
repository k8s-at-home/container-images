FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG TARGETPLATFORM
ARG VERSION

USER root

RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    libchromaprint-tools \
    libicu66 \
  && \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') export ARCH='x64' ;; \
    'linux/arm64') export ARCH='arm64' ;; \
    'linux/arm/v7') export ARCH='arm' ;; \
  esac \
  && \
  curl -fsSL -o /tmp/lidarr.tar.gz \
    "https://lidarr.servarr.com/v1/update/nightly/updatefile?version=${VERSION}&os=linux&runtime=netcore&arch=${ARCH}" \
  && tar ixzf /tmp/lidarr.tar.gz -C /app --strip-components 1 \
  && \
  rm -rf \
    /app/lidarr.Update* \
  && echo "UpdateMethod=docker\nBranch=develop\nPackageVersion=${VERSION}\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" > /app/package_info \
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

EXPOSE 8686

COPY ./apps/lidarr/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
