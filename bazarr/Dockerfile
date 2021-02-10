FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION
ARG TARGETPLATFORM

USER root

RUN \
  export EXTRA_INSTALL_ARG="build-essential libxml2-dev libxslt1-dev python3-dev python3-pip"; \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    python3 \
    python3-distutils \
    ffmpeg \
    unrar \
    unzip \ 
    ${EXTRA_INSTALL_ARG} \
  && \
  ln -s /usr/bin/python3 /usr/bin/python \
  && \
  curl -fsSL "https://github.com/morpheus65535/bazarr/archive/v${VERSION}.tar.gz" | tar xzf - -C /app --strip-components=1 \
  && pip3 install --no-cache-dir -U -r /app/requirements.txt \
  && echo "UpdateMethod=docker\nPackageVersion=${VERSION}\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" > /app/package_info \
  && apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /app/bin \
    /app/tests \
    /app/screenshots \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && echo umask ${UMASK} >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 6767

COPY ./bazarr/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
