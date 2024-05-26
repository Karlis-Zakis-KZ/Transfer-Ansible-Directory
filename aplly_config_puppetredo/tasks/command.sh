#!/bin/bash
command=$PT_command
sshpass -p "$PT_password" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 "$PT_user@$PT_target" "$command"
