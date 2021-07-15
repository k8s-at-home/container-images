# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION

# hadolint ignore=DL3002
USER root

WORKDIR /tmp

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies

WORKDIR /tmp

# hadolint ignore=DL3003,DL3008,DL3013,DL3015,SC2086
RUN \
  echo "**** set the platform ****" \
  && \
  case "${TARGETPLATFORM}" in \
    'linux/amd64') \
      export ARCH='x86_64'; \
      export EXTRA_INSTALL_ARG='beignet-opencl-icd ocl-icd-libopencl1'; \
    ;; \
    'linux/arm64') \
      export ARCH='aarch64'; \
      export EXTRA_INSTALL_ARG=''; \
    ;; \
  esac \
  && \
  echo "**** install packages ****" \
  && \
  apt-get update \
  && \
  apt-get install -y \
    aria2 \
    unrar \
    uuid-runtime \
    cpio \
    jq \
    rpm2cpio \
    ${EXTRA_INSTALL_ARG} \
  && \
  echo "**** install emby ****" \
  && \
  mkdir -p \
    /app \
  && \
  curl -o \
    /tmp/emby.rpm -L \
    "https://github.com/MediaBrowser/Emby.Releases/releases/download/${VERSION}/emby-server-rpm_${VERSION}_${ARCH}.rpm" \
  && \
  cd /tmp \
  && \
  rpm2cpio emby.rpm \
    | cpio -i --make-directories \
  && \
  printf "UpdateMethod=docker\nPackageVersion=%s\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" "${VERSION}" > /app/package_info \
  && \
  mv -t \
    /app \
    /tmp/opt/emby-server/system/* \
    /tmp/opt/emby-server/lib/* \
    /tmp/opt/emby-server/extra/lib/* \
    /tmp/opt/emby-server/bin/ff* \
    /tmp/opt/emby-server/etc


# hadolint ignore=DL3007
FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG TARGETPLATFORM
ARG VERSION

USER root

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility" \
    INTEL_NEO_VERSION=20.48.18558 \
    INTEL_IGC_VERSION=1.0.5699 \
    INTEL_GMMLIB_VERSION=20.3.2 \
    APP_DIR="/app"

# hadolint ignore=DL3008,DL3013,DL3015,SC2086,SC2039
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
	  mesa-va-drivers \
	  uuid-runtime && \
  case "${ARCH}" in \
    'x86_64') \
      curl -J -L -o /tmp/gmmlib.deb https://github.com/intel/compute-runtime/releases/download/${INTEL_NEO_VERSION}/intel-gmmlib_${INTEL_GMMLIB_VERSION}_amd64.deb \
      && apt-get install -y /tmp/gmmlib.deb \
      && curl -J -L -o /tmp/#1.deb https://github.com/intel/intel-graphics-compiler/releases/download/igc-${INTEL_IGC_VERSION}/{intel-igc-core,intel-igc-opencl}_${INTEL_IGC_VERSION}_amd64.deb \
      && apt-get install -y /tmp/intel-igc-core.deb /tmp/intel-igc-opencl.deb \
      && curl -J -L -o /tmp/intel-opencl.deb https://github.com/intel/compute-runtime/releases/download/${INTEL_NEO_VERSION}/intel-opencl_${INTEL_NEO_VERSION}_amd64.deb \
      && apt-get install -y /tmp/intel-opencl.deb \
    ;; \
    'arm64') \
      unset NVIDIA_DRIVER_CAPABILITIES; \
      unset INTEL_NEO_VERSION; \
      unset INTEL_IGC_VERSION; \
      unset INTEL_GMMLIB_VERSION; \
    ;; \
  esac \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/ \
  && chown -R kah:kah /app \
  && chmod -R u=rwX,go=rX "${APP_DIR}" \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates

COPY --from=builder /app /app

USER kah

EXPOSE 8096 8920

COPY ./apps/emby/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
