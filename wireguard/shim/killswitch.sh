#!/usr/bin/env bash

KILLSWITCH=${KILLSWITCH:-"false"}
KILLSWITCH_EXCLUDEDNETWORKS_IPV4=${KILLSWITCH_EXCLUDEDNETWORKS_IPV4:-""}
KILLSWITCH_EXCLUDEDNETWORKS_IPV6=${KILLSWITCH_EXCLUDEDNETWORKS_IPV6:-""}

if
    [[ "${KILLSWITCH}" == "true" ]];
then
    DEFAULTROUTE_IPV4=$(/usr/sbin/ip -4 route | grep default | awk '{print $3}')
    DEFAULTROUTE_IPV6=$(/usr/sbin/ip -6 route | grep default | awk '{print $3}')

    sudo /usr/sbin/iptables -F OUTPUT
    sudo /usr/sbin/ip6tables -F OUTPUT
    if 
        [[ -n "$KILLSWITCH_EXCLUDEDNETWORKS_IPV4" ]];
    then
        IFS=';' read -r -a networks <<< "${KILLSWITCH_EXCLUDEDNETWORKS_IPV4}"
        for entry in "${networks[@]}"
        do
            echo "[INFO] Excluding ${entry} from VPN IPv4 traffic"
            sudo /usr/sbin/ip -4 route add "${entry}" via "$DEFAULTROUTE_IPV4"
            sudo /usr/sbin/iptables -A OUTPUT -d "${entry}" -j ACCEPT
        done

        sudo /usr/sbin/iptables -A OUTPUT ! -o "$INTERFACE" -m mark ! --mark $(sudo /usr/bin/wg show "$INTERFACE" fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
    fi

    if 
        [[ -n "$DEFAULTROUTE_IPV6" ]] && [[ -n "$KILLSWITCH_EXCLUDEDNETWORKS_IPV6" ]];
    then
        IFS=';' read -r -a networks <<< "${KILLSWITCH_EXCLUDEDNETWORKS_IPV6}"
        for entry in "${networks[@]}"
        do
            echo "[INFO] Excluding ${entry} from VPN IPv6 traffic"
            sudo /usr/sbin/ip -6 route add "${entry}" via "$DEFAULTROUTE_IPV6"
            sudo /usr/sbin/ip6tables -A OUTPUT -d "${entry}" -j ACCEPT
        done

        sudo /usr/sbin/ip6tables -A OUTPUT ! -o "$INTERFACE" -m mark ! --mark $(sudo /usr/bin/wg show "$INTERFACE" fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
    fi
fi
