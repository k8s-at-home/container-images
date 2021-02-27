FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION
ARG TARGETPLATFORM

USER root

# Not installed (compared to Alpine version)
# php-pcntl php-posixphp-openssl php-session
RUN \
  export EXTRA_INSTALL_ARG="git" \
  && apt-get -qq update \
  && \
  apt-get -qq install -y \
    php-fpm \
    php-pdo php-gd php-pgsql php-pgsql php-mbstring \
	  php-intl php-xml php-curl \
	  php-dom php-fileinfo php-json php-iconv \
	  php-zip \
	  postgresql-client sudo php-xdebug \
    nginx \
    ${EXTRA_INSTALL_ARG} \
  && git clone https://git.tt-rss.org/fox/tt-rss.git /app \
  && cd /app \
  && if [ -n "$VERSION" ]; then \
    NUMBER_COMMITS_TO_REVERT=$(( $(git rev-list --count --first-parent HEAD) - $(echo $VERSION|cut -d "." -f2) )); \
    git checkout "master~$NUMBER_COMMITS_TO_REVERT"; \
  fi \
  && git clone https://git.tt-rss.org/fox/ttrss-nginx-xaccel.git /apps/plugins.local/nginx_xaccel \
  && chown -R www-data:www-data cache feed-icons lock \
  && cp -a config.php-dist config.php \
  && cd - \
  && sed -i.bak 's/\(memory_limit =\) 128M/\1 256M/' /etc/php/7.4/fpm/php.ini \
  && sed -i.bak 's/;clear_env = .*/clear_env = no/i' /etc/php/7.4/fpm/pool.d/www.conf \
  && echo apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/

COPY ./tt-rss/nginx.conf /etc/nginx/sites-enabled/default
COPY ./tt-rss/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]

#USER kah
#nginx and php use www-data as non-privileged user
#this container does not need to write persistent files - it only persists to DB

EXPOSE 8080
