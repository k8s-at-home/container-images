# Download projector-server
FROM ghcr.io/k8s-at-home/ubuntu:latest AS projector

USER root
WORKDIR /download

RUN apt-get update
RUN \
  apt-get -qq update \
  && apt-get install -y jq unzip

RUN \
     export PS_RELEASES="$(curl -s 'https://api.github.com/repos/JetBrains/projector-server/releases')" \
  && export PS_URL=$(echo $PS_RELEASES | jq -r '. - map(select(.tag_name | contains("agent"))) | first | .assets[0].browser_download_url') \
  && curl -fsSL -o ps.zip "$PS_URL" \
  && unzip ps.zip \
  && mv projector-server-1.0-SNAPSHOT/* . \
  && rm -r ps.zip projector-server-1.0-SNAPSHOT

# Build final container
FROM ghcr.io/k8s-at-home/ubuntu:latest

USER root
WORKDIR /app

# copy projector-server
COPY --from=projector /download /app/projector-server

RUN \
     apt-get -qq update \
  && apt-get -qq -y install \
       # packages for awt
       libxext6 \
       libxrender1 \
       libxtst6 \
       libxi6 \
       libfreetype6 \
       # packages for user convenience
       git \
       bash-completion \
       # packages for IDEA (to disable warnings)
       procps \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/cache/apt/* \
    /var/tmp/ \
  && chmod -R u=rwX,go=rX /app \
  && chown -R kah:kah /app \
  && usermod -d /config kah \
  && printf "umask %d" "${UMASK}" >> /etc/bash.bashrc \
  && update-ca-certificates

USER kah

EXPOSE 8887

COPY ./base/projector/entrypoint.sh /entrypoint.sh
COPY ./base/projector/idea.properties /tmp/idea.properties

CMD ["/entrypoint.sh"]
