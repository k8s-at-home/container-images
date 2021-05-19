# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

# hadolint ignore=DL3002
USER root

WORKDIR /tmp/leaf2mqtt

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  export DART_DEPS="\
    apt-transport-https \
    apt-utils \
    wget \
    gnupg2 \
    git \
  " \
  && apt-get -qq update \
  && apt-get -qq install -y \
    ${DART_DEPS} \
  && wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list \
  && apt-get -qq update \
  && apt-get -qq install -y \
    mosquitto \
    mosquitto-clients \
    dart \
  && mkdir -p /var/run/leaf2mqtt \
  && git clone https://github.com/Troon/leaf2mqtt.git . \
  && dart pub get \
  && dart compile exe leaf2mqtt.dart -o /var/run/leaf2mqtt/leaf2mqtt.exe \
  && dart compile exe leaf_climate.dart -o /var/run/leaf2mqtt/leaf_climate.exe \
  && cp leaf2mqtt.sh /var/run/leaf2mqtt \
  && chown -R kah:kah /var/run/leaf2mqtt \
  && chmod +x /var/run/leaf2mqtt/* \
  && apt-get remove -y ${BUILD_DEPS} dart \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/

WORKDIR /var/run/leaf2mqtt

USER kah
COPY ./apps/leaf2mqtt/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
