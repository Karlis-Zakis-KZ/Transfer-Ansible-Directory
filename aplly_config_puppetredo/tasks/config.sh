#!/bin/bash
config=$PT_config
sshpass -p "$PT_password" ssh -o StrictHostKeyChecking=no "$PT_user@$PT_target" << EOF
enable
conf t
$config
end
write memory
EOF
