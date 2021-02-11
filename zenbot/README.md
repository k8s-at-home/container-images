# Zenbot

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

conf.js is expected in /config
