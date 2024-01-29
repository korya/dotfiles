#!/bin/bash

lib_include color

# Arguments are: <iface> <event>
# where event is one of { CONNECTED, DISCONNECTED }
IFACE="$1"
EVENT="$2"

CLR_DEBUG=$(color_make blue black bold)
CLR_NORMAL=$(color_make)
d()
{
    echo "${CLR_DEBUG}[+] $@${CLR_NORMAL}"
}

d "\$@ = <$@>"
d "IFACE = <$IFACE>; EVENT = <$EVENT>"

case "$EVENT" in
CONNECTED)
    d "Kill all dhclient instances"
    kill -9 $(ps ax | grep dhclient | grep -v grep | cut -d\  -f1)
    d "Associated on $IFACE"
    iwconfig "$IFACE"
    d "Running dhclient"
    dhclient -v -1 "$IFACE"
    if [ $? -eq 0 ]; then
	d "Printing route table"
	route -n
    else
	wpa_cli scan
	wpa_cli reassociate
    fi
    ;;
DISCONNECTED)
    d "Killing dhclient"
    dhclient -r "$IFACE"
    ;;
*)
    d "Got unknown event = <$EVENT>"
    exit 1
esac

d "OK"
exit 0
