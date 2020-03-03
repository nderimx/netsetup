#!/bin/bash
m_flag=''

print_usage() {
	printf "Usage: $0 <new_hostname>
-m      Run without changing hostname. You have to manually change your hostname."
}

if [ $# -eq 0 ]; then
	echo "No arguments supplied."
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
    sudo sed -i 's/$(hostname)/$1/g' /etc/hostname
    sudo sed -i 's/$(hostname)/$1/g' /etc/hosts
fi
hostname $1


sudo cat >> /etc/netplan/* << EOF 
network:
    ethernets:
        enp0s3:
            dhcp4: yes
        enp0s8:
            dhcp4: no
            addresses: [192.168.1.1/24]
            gateway4: 192.168.1.254
EOF

sudo ifconfig enp0s8 down && sudo ifconfig enp0s8 up
sudo netplan try
sudo netplan apply
