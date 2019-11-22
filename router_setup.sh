#!/bin/bash

# later let the user give interface names and ip addresses as arguments, and loop over the given interfaces to connect the corresponding ip addresses

m_flag=''

print_usage() {
	printf "Usage: $0 <new_hostname>
-m      Run without changing hostname. You have to manually change your hostname."
}

if [ $# -eq 0 ]; then
	echo "No arguments supplied. First argument is your custom home path"
    print_usage
	exit 1
fi

while getopts 'mf:v' flag; do
	case "${flag}" in
		m) m_flag='true' ;;
		*) print_usage
			exit 1 ;;
	esac
done

current_host=$(hostname)
if [ ${#current_host} -lt 4 ]; then
    echo "Current hostname is too small. You have to change your hostname manually"
    test ! $m_flag && exit 1
else
    sed -i 's/$(hostname)/$1/g' /etc/hostname
    sed -i 's/$(hostname)/$1/g' /etc/hosts
fi
hostname $1

sudo apt-get update
sudo apt-get install quagga quagga-doc traceroute
sudo touch /etc/quagga/zebra.conf
sudo touch /etc/quagga/ospfd.conf
sudo chown quagga.quaggavty /etc/quagga/*.conf
sudo chmod 640 /etc/quagga/*.conf
sudo cat >> /etc/quagga/zebra.conf << EOF
interface enp0s8
 ip address 192.168.1.254/24
 ipv6 nd suppress-ra
interface enp0s9
 ip address 192.168.100.1/24
 ipv6 nd suppress-ra
interface lo
ip forwarding
line vty
EOF
sudo cat > /etc/quagga/daemons << EOF
zebra=yes
bgpd=no
ospfd=yes
ospf6d=no
ripd=no
ripngd=no
isisd=no
babeld=no
EOF
echo 'VTYSH_PAGER=more' >>/etc/environment 
echo 'export VTYSH_PAGER=more' >>/etc/bash.bashrc
sudo cat >> /etc/quagga/ospfd.conf << EOF
interface enp0s8
interface enp0s9
interface lo
router ospf
 passive-interface enp0s8
 network 192.168.1.0/24 area 0.0.0.0
 network 192.168.100.0/24 area 0.0.0.0
line vty
EOF
sudo ifconfig enp0s8 down && sudo ifconfig enp0s8 up
sudo ifconfig enp0s9 down && sudo ifconfig enp0s9 up
systemctl start ospfd
systemctl start zebra