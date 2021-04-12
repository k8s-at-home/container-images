# Download IDE
FROM ghcr.io/k8s-at-home/projector:latest AS ide

ARG IDE_DOWNLOAD_URL
USER root
WORKDIR /download

RUN curl -fsSL $IDE_DOWNLOAD_URL | tar -xz --strip-components 1

# Build final container
FROM ghcr.io/k8s-at-home/projector:latest

ARG IDE_DOWNLOAD_URL
USER root
WORKDIR /app

# copy IDE
COPY --from=ide /download /app/ide

WORKDIR /data

RUN \
  && if [ "${IDE_DOWNLOAD_URL#*CLion}" != "$IDE_DOWNLOAD_URL" ]; then \
         apt-get -qq -y install build-essential clang; \
     fi \
  && if [ "${IDE_DOWNLOAD_URL#*pycharm}" != "$IDE_DOWNLOAD_URL" ]; then \
         apt-get -qq -y install python2 python3 python3-distutils python3-pip python3-setuptools; \
     fi \
  && if [ "${IDE_DOWNLOAD_URL#*rider}" != "$IDE_DOWNLOAD_URL" ]; then \
            apt-get -qq -y install apt-transport-https dirmngr gnupg ca-certificates \
         && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
         && echo "deb https://download.mono-project.com/repo/debian stable-buster main" | \
            tee /etc/apt/sources.list.d/mono-official-stable.list \
         && apt-get -qq update \
         && apt-get -qq -y install mono-devel \
         && curl -fsSL -O https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb \
         && dpkg -i packages-microsoft-prod.deb \
         && rm packages-microsoft-prod.deb \
         && apt-get -qq update \
         && apt-get -qq -y install apt-transport-https \
         && apt-get -qq update \
         && apt-get -qq -y install \
              dotnet-sdk-3.1 \
              aspnetcore-runtime-3.1; \
     fi \
  # clean apt to reduce image size
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app /data \
  && chown -R kah:kah /app /data \
  && usermod -d /data kah \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 8887

COPY ./apps/projector/entrypoint.sh /entrypoint.sh
COPY ./apps/projector/idea.properties /tmp/idea.properties

CMD ["/entrypoint.sh"]
