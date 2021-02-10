FROM ghcr.io/k8s-at-home/ubuntu:latest

USER root

ARG TARGETPLATFORM
ARG VERSION


RUN \
  export EXTRA_INSTALL_ARG="node-gyp"; \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    nodejs \
    npm \
    build-essential \
    git \
    ${EXTRA_INSTALL_ARG} \
  && \
  curl -fsSL "https://github.com/DeviaVir/zenbot/archive/${VERSION}.tar.gz" | tar xzf - -C /app --strip-components 1 \
  && \
  echo "${VERSION}" > /app/version.txt \
  && \
  echo "unstable" > /app/branch.txt \
  && \
  chown -R kah:kah /app \
  && \
  npm install /app --unsafe \
  && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && \
  apt-get autoremove -y \
  && \
  apt-get clean \
  && rm -rf \
  /app/.github \
  /app/assets \
  /app/docs \
  /app/Dockerfile \
  /app/docker-compose* \
  /app/simulations \
  /app/*.md \
  /app/conf.js \

USER kah

EXPOSE 17365

COPY ./entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
