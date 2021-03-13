FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG TARGETPLATFORM
ARG VERSION

USER root

RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3=3.8.2-0ubuntu2 \
    python3-dev=3.8.2-0ubuntu2 \
    python3-pip \
  && \
  ln -s /usr/bin/python3 /usr/bin/python \
  && \
  curl -fsSL "https://github.com/AppDaemon/appdaemon/archive/${VERSION}.tar.gz" | tar xzf - -C /app --strip-components 1 \
  && \
  pip3 install --no-cache-dir -U . \
  && \
  echo "UpdateMethod=docker\nPackageVersion=${VERSION}\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" > /app/package_info \
  && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chown -R kah:kah /app \
  && echo umask ${UMASK} >> /etc/bash.bashrc \
  && update-ca-certificates

COPY ./appdaemon/appdaemon.yaml.example /app/conf/appdaemon.yaml.example
RUN chown -R kah:kah /app

USER kah

EXPOSE 5050

COPY ./appdaemon/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
