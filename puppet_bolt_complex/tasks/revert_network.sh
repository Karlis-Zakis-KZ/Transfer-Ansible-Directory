#!/bin/bash

set -e

# Parameters
ACL_NAME=$PT_acl_name

# Revert configurations
for ROUTER in R1 R2 R3 R4; do
  # Remove ACL
  /usr/bin/sshpass -p cisco ssh -o StrictHostKeyChecking=no cisco@${ROUTER} "configure terminal
  no ip access-list extended ${ACL_NAME}
  exit"

  # Restore interfaces to default
  /usr/bin/sshpass -p cisco ssh -o StrictHostKeyChecking=no cisco@${ROUTER} "configure terminal
  default interface Ethernet1/0
  default interface Ethernet1/1
  exit"

  # Remove OSPF configuration
  /usr/bin/sshpass -p cisco ssh -o StrictHostKeyChecking=no cisco@${ROUTER} "configure terminal
  no router ospf 1
  exit"
done

echo "Network configuration reverted successfully."
