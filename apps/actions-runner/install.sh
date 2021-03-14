#!/bin/bash -ex
GH_RUNNER_VERSION=$1
TARGETPLATFORM=$2

AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
EXTRA_INSTALL_ARG="\
  build-essential \
  libssl-dev"

# Install prerequisites
apt-get update -qqy
apt-get upgrade -qqy
apt-get install -qqy --no-install-recommends \
    ca-certificates \
    curl \
    git-crypt \
    gettext-base \
    jq \
    file \
    sudo \
    tzdata \
    ${EXTRA_INSTALL_ARG}

# Set up runner user
adduser --disabled-password --gecos "" --uid 1000 runner
usermod -aG sudo runner
echo "runner ALL= EXEC: NOPASSWD:ALL" >> /etc/sudoers.d/runner

# Install Runner
case "${TARGETPLATFORM}" in
    'linux/amd64') ARCH='x64' ;;
    'linux/arm64') ARCH='arm64' ;;
    'linux/arm/v7') ARCH='arm' ;;
esac
mkdir -p /runner
mkdir -p "$RUNNER_ASSETS_DIR"
cd "$RUNNER_ASSETS_DIR"
curl -fsSL -o runner.tar.gz https://github.com/actions/runner/releases/download/v${GH_RUNNER_VERSION}/actions-runner-linux-${ARCH}-${GH_RUNNER_VERSION}.tar.gz
tar xzf ./runner.tar.gz
rm runner.tar.gz
./bin/installdependencies.sh
mv ./externals ./externalstmp
apt-get install -y libyaml-dev
echo "AGENT_TOOLSDIRECTORY=${AGENT_TOOLSDIRECTORY}" > .env
mkdir "${AGENT_TOOLSDIRECTORY}"
chgrp runner "${AGENT_TOOLSDIRECTORY}"
chmod g+rwx "${AGENT_TOOLSDIRECTORY}"

# Install latest kubectl
case "${TARGETPLATFORM}" in
    'linux/amd64') ARCH='amd64' ;;
    'linux/arm64') ARCH='arm64' ;;
    'linux/arm/v7') ARCH='arm' ;;
esac
curl -sLO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${ARCH}/kubectl"
mv kubectl /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl
kubectl version --client

# Install latest helm3
curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version

# Install latest kubeseal
case "${TARGETPLATFORM}" in
    'linux/amd64') ARCH='linux-amd64' ;;
    'linux/arm64') ARCH='arm64' ;;
    'linux/arm/v7') ARCH='arm' ;;
esac
KUBESEAL_VERSION=$(curl -s "https://api.github.com/repos/bitnami-labs/sealed-secrets/releases" | jq --raw-output "map(select(any(.assets[].name; contains(\"kubeseal-${ARCH}\"))))[0].tag_name")
KUBESEAL_VERSION=${KUBESEAL_VERSION:1}
curl -sL -o /usr/local/bin/kubeseal "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${ARCH}"
chmod +x /usr/local/bin/kubeseal
kubeseal --version

# Install latest fluxctl
case "${TARGETPLATFORM}" in
    'linux/amd64') ARCH='amd64' ;;
    'linux/arm64') ARCH='arm64' ;;
    'linux/arm/v7') ARCH='arm' ;;
esac
FLUXCTL_VERSION=$(curl -s "https://api.github.com/repos/fluxcd/flux/releases" | jq --raw-output '.[0].tag_name')
FLUXCTL_VERSION=${FLUXCTL_VERSION}
curl -sL -o /usr/local/bin/fluxctl "https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_${ARCH}"
chmod +x /usr/local/bin/fluxctl
fluxctl version

# Install latest gomplate
case "${TARGETPLATFORM}" in
    'linux/amd64') ARCH='amd64' ;;
    'linux/arm64') ARCH='arm64' ;;
    'linux/arm/v7') ARCH='armv7' ;;
esac
GOMPLATE_VERSION=$(curl -s "https://api.github.com/repos/hairyhenderson/gomplate/releases" | jq --raw-output '.[0].tag_name')
GOMPLATE_VERSION=${GOMPLATE_VERSION:1}
curl -o /usr/local/bin/gomplate -sSL "https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-${ARCH}"
chmod +x /usr/local/bin/gomplate
gomplate -v

# Install latest yq
case "${TARGETPLATFORM}" in
    'linux/amd64') ARCH='amd64' ;;
    'linux/arm64') ARCH='arm64' ;;
    'linux/arm/v7') ARCH='arm' ;;
esac
curl -sL -o /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}"
chmod +x /usr/local/bin/yq
yq --version

# Install latest task for amd64 builds
case "${TARGETPLATFORM}" in
    'linux/amd64') ARCH='amd64' ;;
    'linux/arm64') ARCH='' ;;
    'linux/arm/v7') ARCH='' ;;
esac
if [ -n "$ARCH" ]; then
    curl -sL https://taskfile.dev/install.sh | sh
    mv ./bin/task /usr/local/bin/task
    chmod +x /usr/local/bin/task
    task --version;
fi

# Install latest flux
case "${TARGETPLATFORM}" in
    'linux/amd64') ARCH='amd64' ;;
    'linux/arm64') ARCH='arm64' ;;
    'linux/arm/v7') ARCH='arm' ;;
esac
FLUX_VERSION=$(curl -s "https://api.github.com/repos/fluxcd/flux2/releases" | jq --raw-output '.[0].tag_name')
FLUX_VERSION=${FLUX_VERSION:1}
curl -o flux.tar.gz -sSL "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_${ARCH}.tar.gz"
tar xf flux.tar.gz -C /usr/local/bin flux
rm -rf flux.tar.gz
chmod +x /usr/local/bin/flux
chown root:root /usr/local/bin/flux
flux --version

# Cleanup
apt-get remove -y ${EXTRA_INSTALL_ARG}
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
apt-get autoremove -y
apt-get clean
rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/
