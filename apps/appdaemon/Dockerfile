# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,DL3015
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
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chown -R kah:kah /app \
  && chmod -R u=rwX,go=rX /app \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates

COPY ./apps/appdaemon/appdaemon.yaml.example /app/conf/appdaemon.yaml.example
RUN chown -R kah:kah /app

USER kah

EXPOSE 5050

COPY ./apps/appdaemon/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
