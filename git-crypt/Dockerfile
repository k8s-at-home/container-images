FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION

USER root

RUN \
  export EXTRA_INSTALL_ARG="build-essential libssl-dev" \
  && \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    git \
    openssl \
    ${EXTRA_INSTALL_ARG} \
  && mkdir -p /tmp/src \
  && curl -fsSL -o /tmp/git-crypt.tar.gz \
    "https://github.com/AGWA/git-crypt/archive/${VERSION}.tar.gz" \
  && tar ixzf /tmp/git-crypt.tar.gz -C /tmp/src --strip-components 1 \
  && cd /tmp/src \
  && make -j$(nproc) \
  && make install \
  && apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && update-ca-certificates

USER kah

COPY ./git-crypt/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
