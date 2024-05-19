#!/bin/sh
command=$1

sshpass -p "$PT_password" ssh -o StrictHostKeyChecking=no $PT_user@$PT_host "$command"
