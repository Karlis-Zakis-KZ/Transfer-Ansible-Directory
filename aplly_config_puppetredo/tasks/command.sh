#!/bin/bash
command=$PT_command
sshpass -p "$PT_password" ssh -o StrictHostKeyChecking=no "$PT_user@$PT_target" "$command"
