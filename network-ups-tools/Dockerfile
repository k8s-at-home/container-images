FROM k8sathome/ubuntu:latest

USER root

RUN \
  export BUILD_DEPS="autoconf automake build-essential git libavahi-core-dev libavahi-compat-libdnssd-dev libfreeipmi-dev libgd-dev libmodbus-dev libipmimonitoring-dev libneon27-gnutls-dev libpowerman0-dev libsnmp-dev libtool libltdl-dev libusb-dev libssl-dev pkg-config python3" \
  && apt-get -qq update \
  && apt-get -qq install -y \
    libnss3-dev \
    libwrap0-dev \
    ${BUILD_DEPS} \
  && mkdir -p /var/run/nut \
  && chown kah:kah /var/run/nut \
  && cd /tmp \
  && git clone https://github.com/networkupstools/nut.git nut \
  && cd /tmp/nut \
  && ln -s /usr/bin/python3 /usr/bin/python \
  && ./autogen.sh \
  && ./configure \
    --with-user=kah --with-group=kah \
    --sysconfdir=/etc/nut \
    --libdir=/usr/lib/`gcc -print-multiarch` \
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

USER kah

COPY ./network-ups-tools/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
