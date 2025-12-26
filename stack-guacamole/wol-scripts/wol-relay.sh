#!/bin/sh

DOCKER_BRIDGE="guacd"
LAN_BROADCAST="192.168.0.255"
PORT="9"

echo "Starting WoL relay from $DOCKER_BRIDGE to $LAN_BROADCAST:$PORT"
exec socat -d -d -v -u \
  UDP-RECVFROM:$PORT,interface=$DOCKER_BRIDGE,fork \
  UDP-DATAGRAM:$LAN_BROADCAST:$PORT,broadcast
