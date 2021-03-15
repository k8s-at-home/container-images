# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

# hadolint ignore=DL3002
USER root

WORKDIR /tmp/nut

# hadolint ignore=DL3008,DL3015,SC2086
RUN \
  export BUILD_DEPS="\
    autoconf \
    automake \
    build-essential \
    git \
    libavahi-core-dev \
    libavahi-compat-libdnssd-dev \
    libfreeipmi-dev \
    libgd-dev \
    libipmimonitoring-dev \
    libmodbus-dev \
    libneon27-dev \
    libnss3-dev \
    libpowerman0-dev \
    libsnmp-dev \
    libssl-dev \
    libtool \
    libusb-dev \
    pkg-config \
    python3\
  " \
  && apt-get -qq update \
  && apt-get -qq install -y \
    libfreeipmi17 \
    libipmimonitoring6 \
    libmodbus5 \
    libneon27-gnutls \
    libnss3 \
    libpowerman0 \
    libsnmp35 \
    libltdl7 \
    libusb-0.1-4 \
    libwrap0 \
    ${BUILD_DEPS} \
  && mkdir -p /var/run/nut \
  && git clone https://github.com/networkupstools/nut.git . \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && ./autogen.sh \
  && ./configure \
    --sysconfdir=/etc/nut \
    --libdir=/usr/lib/"$(gcc -print-multiarch)" \
    --with-all \
    --with-ssl --with-nss \
    --with-dev --enable-static \
    --with-statepath=/var/run/nut --with-altpidpath=/var/run/nut \
    --with-pidpath=/var/run/nut \
  && make -j"$(nproc)" \
  && make install \
  && chown -R kah:kah /etc/nut \
  && apt-get remove -y ${BUILD_DEPS} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/

WORKDIR /config

COPY ./apps/network-ups-tools/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
