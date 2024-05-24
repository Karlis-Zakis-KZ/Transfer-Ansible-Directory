#!/bin/bash
set -e

# Parameters
HOST=$PT_host

# Simple SSH command to test connectivity
/usr/bin/sshpass -p cisco ssh -o StrictHostKeyChecking=no karlis@${HOST} "echo 'SSH Connection Successful'"

echo "SSH Connection Test Completed."
