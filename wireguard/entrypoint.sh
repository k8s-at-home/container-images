#!/usr/bin/env bash

set -e

KILLSWITCH=${KILLSWITCH:-"false"}
KILLSWITCH_EXCLUDEDNETWORKS=${KILLSWITCH_EXCLUDEDNETWORKS:-""}

if [[ "$(cat /proc/sys/net/ipv4/conf/all/src_valid_mark)" != "1" ]]; then
    echo "[WARNING] sysctl net.ipv4.conf.all.src_valid_mark=1 is not set" >&2
fi

CONFIGS=`sudo /usr/bin/find /etc/wireguard -type f -printf "%f\n"`
if [[ -z "${CONFIGS}" ]]; then
    echo "[ERROR] No configuration files found in /etc/wireguard" >&2
    exit 1
fi

CONFIG=`echo $CONFIGS | head -n 1`
INTERFACE="${CONFIG%.*}"

sudo /usr/bin/wg-quick up "${INTERFACE}"

if
    [[ "${KILLSWITCH}" == "true" ]];
then
    DEFAULTROUTE_IPV4=$(/usr/sbin/ip -4 route | grep default | awk '{print $3}')
    sudo /usr/sbin/iptables -F OUTPUT
    sudo /usr/sbin/ip6tables -F OUTPUT

    if 
        [[ -n "$KILLSWITCH_EXCLUDEDNETWORKS" ]];
    then
        IFS=';' read -r -a networks <<< "${KILLSWITCH_EXCLUDEDNETWORKS}"
        for entry in "${networks[@]}"
        do
            echo "[INFO] Excluding ${entry} from VPN traffic"
            sudo /usr/sbin/ip -4 route add "${entry}" via "$DEFAULTROUTE_IPV4"
            sudo /usr/sbin/iptables -A OUTPUT -d "${entry}" -j ACCEPT
        done

        sudo /usr/sbin/iptables -A OUTPUT ! -o "$INTERFACE" -m mark ! --mark $(sudo /usr/bin/wg show "$INTERFACE" fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
        sudo /usr/sbin/ip6tables -A OUTPUT ! -o "$INTERFACE" -m mark ! --mark $(sudo /usr/bin/wg show "$INTERFACE" fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
    fi
fi

_shutdown () {
    echo "[INFO] Caught signal, shutting down VPN!"
    sudo /usr/bin/wg-quick down "${INTERFACE}"
}

trap _shutdown SIGTERM SIGINT SIGQUIT

sleep infinity &
wait $!
