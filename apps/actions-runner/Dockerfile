# https://github.com/summerwind/actions-runner-controller/blob/master/runner/Dockerfile
FROM ubuntu:focal

ARG VERSION
ARG TARGETPLATFORM
ENV \
  DEBCONF_NONINTERACTIVE_SEEN=true \
  DEBIAN_FRONTEND=noninteractive
ENV RUNNER_ASSETS_DIR=/runnertmp

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /

COPY ./apps/actions-runner/install.sh /install.sh

RUN \
  chmod +x /install.sh \
  && /install.sh ${VERSION} ${TARGETPLATFORM} \
  && rm /install.sh

COPY ./apps/actions-runner/entrypoint.sh /entrypoint.sh
COPY ./apps/actions-runner/patched $RUNNER_ASSETS_DIR/patched

USER runner
CMD ["/entrypoint.sh"]
