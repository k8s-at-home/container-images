# Container Images

Kubernetes tailored container images for various applications. Hosted at https://hub.docker.com/r/k8sathome. 

Applications are checked every several hours for new releases.

## Purpose

_There's so many images out there, why do I want to use these?_

- Semantic versioning is awesome
- s6-overlay is not awesome
- ARM architectures are gaining popularity
- Multiple architecture support (amd64, arm64)
- Simplicity over complexity (e.g. only ubuntu:focal)

## Deployment Information

### Deployment on Kubernetes

Most of these containers can be used as drop-in-replacements for the images in our k8s-at-home [Helm charts](https://github.com/k8s-at-home/charts/).
While we do not know if (or when) these containers will be the default for the Helm Charts, they work just fine!

Within docker-compose and other solutions, they should work just fine too but that isn't guaranteed. 
But please do report any bugs when you see them!

### Volumes
|   Path    | Description                         |
|:---------:|-------------------------------------|
|  `/app`   | Application install directory       |
| `/config` | Application configuration directory |

### Permissions:

Our default permissions are set for user 568.
However: With these containers, permissions are not set using environment variables.

Switching to these images might requires you to either:
1. change permissions to the Persistent Volume (from PVC) (example: `chown -R 568:568 /path/to/volume/`)
or
2. setting the podSecurityContext in the helm charts to your user/group ids, like below:
```
podSecurityContext:
  runAsUser: 1001
  runAsGroup: 1001
  fsGroup: 1001
```
### Environment Variables
|      Name      | Default | Description                                       |
|:--------------:|:-------:|---------------------------------------------------|
|    `UMASK`     | `0002`  | Set the default creation permission mode of files |
| `WAIT_FOR_VPN` | `false` |                                                   |
|  `EXTRA_ARGS`  |         | Additional arguements to pass to the application  |
|      `TZ`      |  `UTC`  | Set to your timezone (e.g. `America/New_York`)    |

## Available Images
|                        Application                        |                                                                                                                                                     |                                                                                                                                                                                                               |
|:---------------------------------------------------------:|-----------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     [actions-runner](https://github.com/summerwind/actions-runner-controller)     | [![Version](https://img.shields.io/docker/v/k8sathome/actions-runner?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/actions-runner)           | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/actions-runner?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Aactions-runner)           |
|     [bazarr](https://github.com/morpheus65535/bazarr)     | [![Version](https://img.shields.io/docker/v/k8sathome/bazarr?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/bazarr)           | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/bazarr?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Abazarr)           |
|       [jackett](https://github.com/Jackett/Jackett)       | [![Version](https://img.shields.io/docker/v/k8sathome/jackett?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/jackett)         | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/jackett?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Ajackett)         |
|        [lidarr](https://github.com/lidarr/Lidarr)         | [![Version](https://img.shields.io/docker/v/k8sathome/lidarr?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/lidarr)           | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/lidarr?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Alidarr)           |
|        [nzbget](https://github.com/nzbget/nzbget)         | [![Version](https://img.shields.io/docker/v/k8sathome/nzbget?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/nzbget)           | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/nzbget?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Anzbget)           |
|    [nzbhydra2](https://github.com/theotherp/nzbhydra2)    | [![Version](https://img.shields.io/docker/v/k8sathome/nzbhydra2?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/nzbhydra2)     | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/nzbhydra2?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Anzbhydra2)     |
|         [ombi](https://github.com/tidusjar/Ombi)          | [![Version](https://img.shields.io/docker/v/k8sathome/ombi?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/ombi)               | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/ombi?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Aombi)               |
| [qbittorrent](https://github.com/qbittorrent/qBittorrent) | [![Version](https://img.shields.io/docker/v/k8sathome/qbittorrent?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/qbittorrent) | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/qbittorrent?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Aqbittorrent) |
|        [radarr](https://github.com/Radarr/Radarr)         | [![Version](https://img.shields.io/docker/v/k8sathome/radarr?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/radarr)           | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/radarr?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Aradarr)           |
|       [sabnzbd](https://github.com/sabnzbd/sabnzbd)       | [![Version](https://img.shields.io/docker/v/k8sathome/sabnzbd?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/sabnzbd)         | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/sabnzbd?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Asabnzbd)         |
|        [sonarr](https://github.com/Sonarr/Sonarr)         | [![Version](https://img.shields.io/docker/v/k8sathome/sonarr?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/sonarr)           | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/sonarr?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Asonarr)           |
|        [tautulli](https://github.com/Tautulli/Tautulli)         | [![Version](https://img.shields.io/docker/v/k8sathome/tautulli?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/tautulli)           | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/tautulli?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Atautulli)           |
|      [wireguard](https://github.com/WireGuard/wireguard-tools)      | [![Version](https://img.shields.io/docker/v/k8sathome/wireguard?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/wireguard)             | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/wireguard?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Awireguard)             |
|      [xteve](https://github.com/xteve-project/xTeVe)      | [![Version](https://img.shields.io/docker/v/k8sathome/xteve?sort=semver&style=for-the-badge)](https://hub.docker.com/r/k8sathome/xteve)             | [![Status](https://img.shields.io/github/workflow/status/k8s-at-home/container-images/xteve?style=for-the-badge)](https://github.com/k8s-at-home/container-images/actions?query=workflow%3Axteve)             |
