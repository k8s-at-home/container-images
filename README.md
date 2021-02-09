# Container Images

Kubernetes tailored container images for various applications, hosted on Github Container Registry.

Applications are checked every several hours for new releases.

## Purpose

The goal of these images is to support:

- semantic versioning
- multiple architectures (`amd64`/`arm64`)
- Kubernetes [Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) over using `s6-overlay`
- only using `ubuntu:focal` as the base image

## Configuration

Most of these images can be used as drop-in-replacements for the images in our k8s-at-home [Helm charts](https://github.com/k8s-at-home/charts/).

## Permissions

These images are using user and group ids of `568`. This cannot be changed at the container runtime.

With that said however there are two methods you can use to make these containers have write access to your file storage:

1. Changing the Kubernetes [Security Contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) to allow the container to have permissions to write to your file storage. In our [Helm charts](https://github.com/k8s-at-home/charts/) this can be accomplished by setting the `podSecurityContext.runAsUser`, `podSecurityContext.runAsGroup`, and `podSecurityContext.fsGroup` values to your required user / group ids.

2. Access the volume's data without the pod running and running `chown -R 568:568 <path-to-your-volume>`.  This step can be a bit complicated if you are not very familiar with your storage interface.

### Environment Variables

|      Name      | Default | Description                                       |
|:--------------:|:-------:|---------------------------------------------------|
|    `UMASK`     | `0002`  | Set the default creation permission mode of files |
| `WAIT_FOR_VPN` | `false` |                                                   |
|  `EXTRA_ARGS`  |         | Additional arguments to pass to the application   |
|      `TZ`      |  `UTC`  | Timezone (e.g. `America/New_York`)                |

### Volumes

|   Path    | Description                         |
|:---------:|-------------------------------------|
|  `/app`   | Application install directory       |
| `/config` | Application configuration directory |
