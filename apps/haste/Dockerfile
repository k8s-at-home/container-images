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
  wget -q "https://github.com/seejohnrun/haste-server/archive/${VERSION}.tar.gz" && \
  tar -xvf "${VERSION}.tar.gz" -C /app --strip-components 1
WORKDIR /app
RUN \
  echo "**** build app ****" && \
  mkdir /app/data && \
  npm install && \
  npm install redis@0.8.1 && \
  npm install pg@4.1.1 && \
  npm install memcached@2.2.2 && \
  npm install aws-sdk@2.738.0 && \
  npm install rethinkdbdash@2.3.31

# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest
ARG VERSION
ENV NODE_ENV=production
ENV APP_DIR="/app"
ENV STORAGE_TYPE=memcached \
    STORAGE_HOST=127.0.0.1 \
    STORAGE_PORT=11211\
    STORAGE_EXPIRE_SECONDS=2592000\
    STORAGE_DB=2 \
    STORAGE_AWS_BUCKET= \
    STORAGE_AWS_REGION= \
    STORAGE_USENAMER= \
    STORAGE_PASSWORD= \
    STORAGE_FILEPATH=

ENV LOGGING_LEVEL=verbose \
    LOGGING_TYPE=Console \
    LOGGING_COLORIZE=true

ENV HOST=0.0.0.0\
    PORT=7777\
    KEY_LENGTH=10\
    MAX_LENGTH=400000\
    STATIC_MAX_AGE=86400\
    RECOMPRESS_STATIC_ASSETS=true

ENV KEYGENERATOR_TYPE=phonetic \
    KEYGENERATOR_KEYSPACE=

ENV RATELIMITS_NORMAL_TOTAL_REQUESTS=500\
    RATELIMITS_NORMAL_EVERY_MILLISECONDS=60000 \
    RATELIMITS_WHITELIST_TOTAL_REQUESTS= \
    RATELIMITS_WHITELIST_EVERY_MILLISECONDS=  \
    # comma separated list for the whitelisted \
    RATELIMITS_WHITELIST=example1.whitelist,example2.whitelist \
    \
    RATELIMITS_BLACKLIST_TOTAL_REQUESTS= \
    RATELIMITS_BLACKLIST_EVERY_MILLISECONDS= \
    # comma separated list for the blacklisted \
    RATELIMITS_BLACKLIST=example1.blacklist,example2.blacklist
ENV DOCUMENTS=about=./about.md
USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
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
  && chown -R kah:kah "${APP_DIR}" \
  && chmod -R u=rwX,go=rX "${APP_DIR}" \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates
COPY --from=builder --chown=kah:kah /app /app
RUN ls /app
STOPSIGNAL SIGINT
WORKDIR /app
VOLUME /app
USER kah
EXPOSE ${PORT}
COPY ./apps/haste/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
