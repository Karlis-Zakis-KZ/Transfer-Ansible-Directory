enable
configure t
hostname R1
no ip domain-lookup
username Karlis priv 15 pass cisco
ip domain-name cisco.com
ip ssh ver 2
crypto key gen rsa mod 1024
line vty 0 4
trans in all
login local
exit
vrf definition MGMT
address-family ipv4
exit
exit
int e1/0
vrf forwarding MGMT
ip add 192.168.21.11 255.255.255.0
no shutdown
end
exit
write memory


