# Testing
#!/bin/sh
vtysh <<- EOF
configure terminal
hostname ${TARGET_NAME}
exit
write memory
EOF
