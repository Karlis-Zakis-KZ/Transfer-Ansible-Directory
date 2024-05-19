#!/bin/sh

# Script to run IOS command via SSH
sshpass -p "$PT_password" ssh -o StrictHostKeyChecking=no "$PT_user@$PT_host" "$PT_command"
