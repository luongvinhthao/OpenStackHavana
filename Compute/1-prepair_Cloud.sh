#!/usr/bin/bash 
source config.cnf
set -e 

if [ -f /etc/network/interfaces ]; then
	cp /etc/network/interfaces /etc/network/interfaces.bak
fi
cat << EOF > /etc/network/interfaces
#Dat IP cho Controller node
# LOOPBACK NET 
auto lo
iface lo inet loopback

# EXT NETWORK
auto eth0
iface eth0 inet static
address $HOST_IP_COMPUTE
netmask 255.255.255.0
gateway $HOST_GATEWAY
dns-nameservers 8.8.8.8

# DATA NETWORK
auto eth1
iface eth1 inet static
address $LOCAL_IP_COMPUTE
netmask 255.255.255.0

EOF

/etc/init.d/networking restart 

sleep 5
echo "---------------------------- Enable IP forwarding ----------------------------"
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
sysctl -p
echo "---------------------------- update ubuntu package----------------------------"

apt-get install -y python-software-properties && add-apt-repository cloud-archive:havana -y
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade 
if [ $? == 1 ] 
then 
	exit 0 
fi
echo "----------------------------  Hostname cho ubuntu ----------------------------"
hostname $HOST_NAME_COMPUTE
echo "$HOST_NAME_COMPUTE" > /etc/hostname


echo "---------------------------- DNS controller ----------------------------"
cat << EOF > /etc/hosts
127.0.0.1       localhost
$HOST_IP      controller

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF


echo "---------------------------- Install NTP ----------------------------"
apt-get install -y ntp

echo "---------------------------- Restart NTP ----------------------------"
sleep 3
service ntp restart
echo "---------------------------- install Messaging server  ----------------------------"
apt-get install -y rabbitmq-server
echo "$RABBIT_PASS"
rabbitmqctl change_password guest $RABBIT_PASS

echo "---------------------------- Restart ----------------------------"
sleep 2
service rabbitmq-server restart
sleep 2
init 6


 
