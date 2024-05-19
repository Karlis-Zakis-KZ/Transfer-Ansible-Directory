#!/bin/sh

sshpass -p "$PT_password" ssh -o StrictHostKeyChecking=no "$PT_user@$PT_host" "$PT_command"
