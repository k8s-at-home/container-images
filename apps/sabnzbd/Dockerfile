# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008,DL3013,DL3015,SC2086
RUN \
  export EXTRA_INSTALL_ARG="build-essential libffi-dev libssl-dev python3-dev python3-pip"; \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    p7zip-full \
    par2 \
    python3 \
    python3-distutils \
    unrar \
    unzip \
    ${EXTRA_INSTALL_ARG} \
  && \
  ln -s /usr/bin/python3 /usr/bin/python \
  && \
  curl -fsSL "https://github.com/sabnzbd/sabnzbd/releases/download/${VERSION}/SABnzbd-${VERSION}-src.tar.gz" | tar xzf - -C /app --strip-components=1 \
  && \
  pip3 install --no-cache-dir -U -r /app/requirements.txt \
  && \
  printf "UpdateMethod=docker\nPackageVersion=%s\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" "${VERSION}" > /app/package_info \
  && \
  pip3 install --no-cache-dir -U \
    apprise \
  && apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
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

USER kah

EXPOSE 8080

COPY ./apps/sabnzbd/sabnzbd.ini /app/sabnzbd.ini

COPY ./apps/sabnzbd/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
