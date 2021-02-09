FROM ghcr.io/k8s-at-home/ubuntu:latest

ARG VERSION

USER root

RUN \
  export EXTRA_INSTALL_ARG="build-essential git" \
  && apt-get -qq update \
  && \
  apt-get -qq install -y \
    iptables \
    iproute2 \
    openresolv \
    sudo \
    ${EXTRA_INSTALL_ARG} \
  && git clone https://git.zx2c4.com/wireguard-linux-compat \
  && git clone https://git.zx2c4.com/wireguard-tools \
  && cd wireguard-tools \
  && git checkout "v${VERSION}" \
  && make -C src -j$(nproc) \
  && make -C src install \
  && sed -i "s:sysctl -q net.ipv4.conf.all.src_valid_mark=1:# skipping setting net.ipv4.conf.all.src_valid_mark:" /usr/bin/wg-quick \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/sbin/iptables -F OUTPUT" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/sbin/ip6tables -F OUTPUT" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/sbin/iptables -A OUTPUT *" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/sbin/ip6tables -A OUTPUT *" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/sbin/ip -4 route add *" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/sbin/ip -6 route add *" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/bin/wg show *" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/bin/wg-quick up *" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/bin/wg-quick down *" >> /etc/sudoers.d/kah \
  && echo "kah ALL= EXEC: NOPASSWD: /usr/bin/find /etc/wireguard -type f *" >> /etc/sudoers.d/kah \
  && echo 'Defaults env_keep +="TZ"' >> /etc/sudoers.d/kah \
  && echo "UpdateMethod=docker\nPackageVersion=${VERSION}\nPackageAuthor=[Team k8s-at-home](https://github.com/k8s-at-home)" > /app/package_info \
  && apt-get remove -y ${EXTRA_INSTALL_ARG} \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
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

COPY ./wireguard/shim/* /shim
COPY ./wireguard/entrypoint.sh /entrypoint.sh
CMD ["/entrypoint.sh"]
