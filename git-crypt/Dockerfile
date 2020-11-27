FROM k8sathome/ubuntu:latest

ARG VERSION

USER root

RUN \
  export EXTRA_INSTALL_ARG="build-essential libssl-dev" \
  && apt-get -qq update \
  && \
  apt-get -qq install -y --no-install-recommends --no-install-suggests \
    git \
    openssl \
    ${EXTRA_INSTALL_ARG} \
  && git clone https://github.com/AGWA/git-crypt.git \
  && cd git-crypt \
  && git checkout "${VERSION}" \
  && make -C . -j$(nproc) \
  && make -C . install \
  && apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/

USER kah

COPY ./git-crypt/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
