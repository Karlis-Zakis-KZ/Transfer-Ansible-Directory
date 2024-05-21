#!/bin/sh

ssh karlis@$TARGET_NAME << EOF
configure terminal
hostname $TARGET_NAME
exit
write memory
EOF
