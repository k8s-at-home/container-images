FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG TARGETPLATFORM
ARG VERSION

USER root

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    INTEL_NEO_VERSION=20.48.18558 \
    INTEL_IGC_VERSION=1.0.5699 \
    INTEL_GMMLIB_VERSION=20.3.2 \
    PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server-new" \
    PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
    PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
    PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
    PLEX_MEDIA_SERVER_USER="kah" \
    PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
    PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (k8s-at-home)"

RUN \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') \
        export ARCH='amd64'; \
        export EXTRA_INSTALL_ARG='beignet-opencl-icd ocl-icd-libopencl1'; \
    ;; \
    'linux/arm64') \
        export ARCH='arm64'; \
        export EXTRA_INSTALL_ARG=''; \
        unset NVIDIA_DRIVER_CAPABILITIES; \
        unset INTEL_NEO_VERSION; \
        unset INTEL_IGC_VERSION; \
        unset INTEL_GMMLIB_VERSION; \
    ;; \
  esac \
  && \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    aria2 \
    unrar \
    uuid-runtime \
    xmlstarlet \
    ${EXTRA_INSTALL_ARG} \
  && \
  case "${ARCH}" in \
    'amd64') \
      curl -J -L -o /tmp/gmmlib.deb https://github.com/intel/compute-runtime/releases/download/${INTEL_NEO_VERSION}/intel-gmmlib_${INTEL_GMMLIB_VERSION}_amd64.deb \
      && apt install -y /tmp/gmmlib.deb \
      && curl -J -L -o /tmp/#1.deb https://github.com/intel/intel-graphics-compiler/releases/download/igc-${INTEL_IGC_VERSION}/{intel-igc-core,intel-igc-opencl}_${INTEL_IGC_VERSION}_amd64.deb \
      && apt install -y /tmp/intel-igc-core.deb /tmp/intel-igc-opencl.deb \
      && curl -J -L -o /tmp/intel-opencl.deb https://github.com/intel/compute-runtime/releases/download/${INTEL_NEO_VERSION}/intel-opencl_${INTEL_NEO_VERSION}_amd64.deb \
      && apt install -y /tmp/intel-opencl.deb \
    ;; \
  esac \
  && \
  echo "Using curl or wget to download the plex debian package result in a qemu failure, why? I dunno" \
  && \
  aria2c -d /tmp -o plex.deb \
    "${PLEX_DOWNLOAD}/${VERSION}/debian/plexmediaserver_${VERSION}_${ARCH}.deb" \
  && \
  dpkg -i --force-confold --force-architecture /tmp/plex.deb \
  && \
  echo "UpdateMethod=docker\nPackageVersion=${VERSION}\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" > /app/package_info \
  && apt-get remove -y aria2 \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /etc/default/plexmediaserver \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && echo umask ${UMASK} >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 32400/tcp 1900/udp 3005/tcp 5353/udp 8324/tcp 32410/udp 32412/udp 32413/udp 32414/udp 32469/tcp

COPY ./apps/plex-media-server/shim/plex-preferences.sh /shim/plex-preferences.sh

COPY ./apps/plex-media-server/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
