#!/bin/bash

set -e

# Parameters
IP_RANGE=$PT_ip_range
WILDCARD_MASK=$PT_wildcard_mask
ACL_NAME=$PT_acl_name

# Apply interface configurations
for ROUTER in R1 R2 R3 R4; do
  if [ "$ROUTER" == "R1" ]; then
    INTERFACE1="Ethernet1/0"
    IP1="192.168.21.11"
    INTERFACE2="Ethernet1/1"
    IP2="192.168.22.1"
  elif [ "$ROUTER" == "R2" ]; then
    INTERFACE1="Ethernet1/0"
    IP1="192.168.21.12"
    INTERFACE2="Ethernet1/1"
    IP2="192.168.23.1"
  elif [ "$ROUTER" == "R3" ]; then
    INTERFACE1="Ethernet1/0"
    IP1="192.168.21.13"
    INTERFACE2="Ethernet1/1"
    IP2="192.168.24.1"
  elif [ "$ROUTER" == "R4" ]; then
    INTERFACE1="Ethernet1/0"
    IP1="192.168.21.14"
    INTERFACE2="Ethernet1/1"
    IP2="192.168.25.1"
  fi

  # Configure interfaces
  /usr/bin/sshpass -p cisco ssh -o StrictHostKeyChecking=no cisco@${ROUTER} "configure terminal
  interface ${INTERFACE1}
  ip address ${IP1} 255.255.255.0
  no shutdown
  interface ${INTERFACE2}
  ip address ${IP2} 255.255.255.0
  no shutdown
  exit"

  # Configure OSPF
  /usr/bin/sshpass -p cisco ssh -o StrictHostKeyChecking=no cisco@${ROUTER} "configure terminal
  router ospf 1
  network 192.168.21.0 0.0.0.255 area 0
  network ${IP2}/24 area 0
  exit"

  # Apply ACL
  /usr/bin/sshpass -p cisco ssh -o StrictHostKeyChecking=no cisco@${ROUTER} "configure terminal
  ip access-list extended ${ACL_NAME}
  permit ip ${IP_RANGE} ${WILDCARD_MASK} any
  exit"
done

echo "Network configuration applied successfully."
