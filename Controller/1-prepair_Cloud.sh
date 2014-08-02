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
address $HOST_IP
netmask 255.255.255.0
gateway $HOST_GATEWAY
dns-nameservers 8.8.8.8

# DATA NETWORK
auto eth1
iface eth1 inet static
address $LOCAL_IP
netmask 255.255.255.0

EOF

/etc/init.d/networking restart 

sleep 5

echo "---------------------------- cap nhat cac goi cho ubuntu ----------------------------"

apt-get install -y python-software-properties && add-apt-repository cloud-archive:havana -y
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade 
if [ $? == 1 ] 
then 
	exit 0 
fi
echo "---------------------------- Khai bao Hostname cho ubuntu ----------------------------"
hostname $HOST_NAME
echo "$HOST_NAME" > /etc/hostname

echo "---------------------------- Cai dat & cau hinh NTP ----------------------------"
apt-get install -y ntp

echo "---------------------------- Khoi dong lai NTP ----------------------------"
sleep 3
service ntp restart
echo "---------------------------- install Messaging server cho ubuntu ----------------------------"
apt-get install -y rabbitmq-server
echo "$RABBIT_PASS"
rabbitmqctl change_password guest $RABBIT_PASS

echo "---------------------------- Khoi dong lai may ----------------------------"
sleep 2
service rabbitmq-server restart
sleep 2
init 6


 
