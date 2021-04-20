# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION

USER root

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  apt-get -qq update \
  &&\
  apt-get -qq install -y \
    openjdk-11-jre-headless \
    python3 \
    unzip \
  && \
  ln -s /usr/bin/python3 /usr/bin/python \
  && \
  curl -fsSL -o /tmp/nzbhydra2.zip \
    "https://github.com/theotherp/nzbhydra2/releases/download/v${VERSION}/nzbhydra2-${VERSION}-linux.zip" \
  && unzip -q /tmp/nzbhydra2.zip -d /app \
  && curl -fsSL -o /app/nzbhydra2wrapperPy3.py \
    "https://raw.githubusercontent.com/theotherp/nzbhydra2/v${VERSION}/other/wrapper/nzbhydra2wrapperPy3.py" \
  && \
  apt-get remove -y unzip \
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

EXPOSE 5076

COPY ./apps/nzbhydra2/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
