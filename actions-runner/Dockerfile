# https://github.com/summerwind/actions-runner-controller/blob/master/runner/Dockerfile
ARG UBUNTUVERSION=focal
FROM ubuntu:${UBUNTUVERSION}

ARG VERSION
ARG TARGETPLATFORM
ENV \
  DEBCONF_NONINTERACTIVE_SEEN=true \
  DEBIAN_FRONTEND=noninteractive

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
WORKDIR /

COPY ./actions-runner/install.sh /install.sh

RUN \
  chmod +x /install.sh \
  && /install.sh ${VERSION} ${TARGETPLATFORM} \
  && rm /install.sh

COPY ./actions-runner/entrypoint.sh /runner/entrypoint.sh
COPY ./actions-runner/patched /runner/patched

USER runner
CMD ["/runner/entrypoint.sh"]
