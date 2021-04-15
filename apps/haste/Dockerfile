# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest AS builder
ARG VERSION
WORKDIR /tmp
ARG FILENAME="${VERSION}.tar.gz"
# hadolint ignore=DL3002
USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# hadolint ignore=DL3008,DL3015,SC2039,SC2086
RUN \
  echo "**** install packages ****" \
  && \
  apt-get update \
  && \
  apt-get install -y \
    wget \
    npm \
  && \
  echo "**** download haste ****" \
  && \
  wget -q "https://github.com/zneix/haste-server/archive/${VERSION}.tar.gz" && \
  tar -xvf "${VERSION}.tar.gz" -C /app --strip-components 1
WORKDIR /app
RUN \
  echo "**** update config.js ****" && \
  mv ./example.config.js config.js && \
  sed -i "s@\"host\": \"127.0.0.1\"@\"host\": \"0.0.0.0\"@" /app/config.js && \
  echo "**** build app ****" && \
  mkdir /app/data && \
  npm run-script build

# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest
ARG VERSION
ENV NODE_ENV=production
ENV APP_DIR="/app"
USER root
# hadolint ignore=DL3008,DL3015,SC2039,SC2086
RUN \
  echo "**** install packages ****" \
  && \
  apt-get update \
  && \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && \
  apt-get install -y \
    nodejs \
  && \
  printf "UpdateMethod=docker\nPackageVersion=%s\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" "${VERSION}" > /app/package_info \
  && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && \
  apt-get autoremove -y \
  && \
  apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX "${APP_DIR}" \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates
COPY --from=builder --chown=kah:kah /app /app
WORKDIR /app
VOLUME /app
USER kah
EXPOSE 7777
COPY ./apps/haste/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
