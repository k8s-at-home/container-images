#
# NOTE: qbittorrent >= 4.3.0 requires libtorrent-rasterbar >= 1.2
# hence all the scattered logic written below
#

FROM k8sathome/ubuntu:latest as builder

ARG TARGETPLATFORM
ARG VERSION

USER root

WORKDIR /tmp

# Install system dependencies
RUN \
  apt-get -qq update \
  && \
  apt-get -qq install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libboost-chrono-dev \
    libboost-dev \
    libboost-random-dev \
    libboost-system-dev \
    libgeoip-dev \
    libqt5svg5-dev \
    libssl-dev \
    ninja-build \
    pkg-config \
    qtbase5-dev \
    qttools5-dev \
    zlib1g-dev

# Install lintorrent-rasterbar dependencies
RUN \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') export ARCH='amd64' ;; \
    'linux/arm64') export ARCH='arm64' ;; \
    'linux/arm/v7') export ARCH='armhf' ;; \
  esac \
  && echo "arch: ${ARCH}" \
  && \
  export LIBTORRENT_DEB="libtorrent-rasterbar10_1.2.12+git20210118.3efdb8a941-1ppa1~20.04_${ARCH}.deb" \
  && export LIBTORRENT_DEV_DEB="libtorrent-rasterbar-dev_1.2.12+git20210118.3efdb8a941-1ppa1~20.04_${ARCH}.deb" \
  && echo "libtorrent deb: ${LIBTORRENT_DEB}" \
  && echo "libtorrent-dev deb: ${LIBTORRENT_DEB}" \
  && \
  curl -fsSL -o libtorrent-rasterbar.deb \
    "https://launchpad.net/~qbittorrent-team/+archive/ubuntu/qbittorrent-stable/+files/${LIBTORRENT_DEB}" \
  && dpkg -i libtorrent-rasterbar.deb \
  && rm -rf libtorrent-rasterbar.deb \
  && \
  curl -fsSL -o libtorrent-rasterbar-dev.deb \
    "https://launchpad.net/~qbittorrent-team/+archive/ubuntu/qbittorrent-stable/+files/${LIBTORRENT_DEV_DEB}" \
  && dpkg -i libtorrent-rasterbar-dev.deb \
  && rm -rf libtorrent-rasterbar-dev.deb

# Compile qbitorrent
RUN \
  git clone --depth 1 -b release-${VERSION} https://github.com/qbittorrent/qBittorrent.git . \
  && \
  case "${TARGETPLATFORM}" in \
    'linux/arm/v7') export EXTRA_CFG_ARG="--with-boost-libdir=/usr/lib/arm-linux-gnueabihf" ;; \
  esac \
  && ./configure ${EXTRA_CFG_ARG} --disable-gui --disable-stacktrace \
  && make \
  && make install

FROM k8sathome/ubuntu:latest

ARG TARGETPLATFORM
ARG VERSION

# Proper way to set config directory
ENV HOME=/config \
    XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/config \
    WEBUI_PORT=8080

USER root

COPY --from=builder /usr/local/bin/qbittorrent-nox /app/qbittorrent-nox

RUN \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') export ARCH='amd64' ;; \
    'linux/arm64') export ARCH='arm64' ;; \
    'linux/arm/v7') export ARCH='armhf' ;; \
  esac \
  && \
  export LIBTORRENT_DEB="libtorrent-rasterbar10_1.2.12+git20210118.3efdb8a941-1ppa1~20.04_${ARCH}.deb" \
  && \
  curl -fsSL -o libtorrent-rasterbar.deb \
    "https://launchpad.net/~qbittorrent-team/+archive/ubuntu/qbittorrent-stable/+files/${LIBTORRENT_DEB}" \
  && dpkg -i libtorrent-rasterbar.deb \
  && rm -rf libtorrent-rasterbar.deb \
  && \
  apt-get -qq update \
  && \
  apt-get install -y \
    geoip-bin \
    libqt5network5 \
    libqt5xml5 \
    p7zip-full \
    python3 \
    unrar \
    unzip \
  && echo "UpdateMethod=docker\nPackageVersion=${VERSION}\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" > /app/package_info \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && echo umask ${UMASK} >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 6881 6881/udp ${WEBUI_PORT}

COPY /qbittorrent/qBittorrent.conf /app/qBittorrent.conf

COPY ./qbittorrent/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
