# Wireguard

Non-root Docker image running [WireGuard](https://www.wireguard.com).

## Requirements

- Kernel 5.6+ for Debian/Ubuntu and others or build the WireGuard kernel module

The following capabilities are required for running this container:
- NET_ADMIN
- SYS_MODULE

The container runs as a non-privileged user. This user should **not** be changed (e.g. via a `securitycontext`), or the container will not work!

## Configuration

You will need a configuration file for your Wireguard interface.
Mount this configuration file to /etc/wireguard/ (e.g. `/etc/wireguard/wg0.conf`)

| Environment variable             | Description                                                                     | Default value |
| -------------------------------- | ------------------------------------------------------------------------------- | ------------- |
| IPTABLES_BACKEND                 | Override the backend used by iptables. Valid values are `nft` and `legacy`      |               |
| KILLSWITCH                       | Enable a killswitch that kills all trafic when the VPN is not connected         | `false`       |
| KILLSWITCH_EXCLUDEDNETWORKS_IPV4 | A separated list of IPv4 networks that will be excluded from the VPN/killswitch |               |
| KILLSWITCH_EXCLUDEDNETWORKS_IPV6 | A separatedlist of IPv6 networks that will be excluded from the VPN/killswitch  |               |
| SEPARATOR                        | The separator that is used to split the `KILLSWITCH_EXCLUDEDNETWORKS` lists     | `;`           |
