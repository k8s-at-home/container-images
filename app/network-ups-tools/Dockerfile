FROM ghcr.io/k8s-at-home/ubuntu:latest

USER root

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
  && cd /tmp \
  && git clone https://github.com/networkupstools/nut.git nut \
  && cd /tmp/nut \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && ./autogen.sh \
  && ./configure \
    --sysconfdir=/etc/nut \
    --libdir=/usr/lib/`gcc -print-multiarch` \
    --with-all \
    --with-ssl --with-nss \
    --with-dev --enable-static \
    --with-statepath=/var/run/nut --with-altpidpath=/var/run/nut \
    --with-pidpath=/var/run/nut \
  && make -j \
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

COPY ./apps/network-ups-tools/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
