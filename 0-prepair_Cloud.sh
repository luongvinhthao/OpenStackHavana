#!/usr/bin/bash 
source config.cfg


echo "---------------------------- cap nhat cac goi cho ubuntu ----------------------------"
apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade 
apt-get install -y python-software-properties
add-apt-repository cloud-archive:havana
echo "---------------------------- Khai bao Hostname cho ubuntu ----------------------------"
sleep 2
hostname controller
echo "controller" > /etc/hostname

echo "---------------------------- Cai dat & cau hinh NTP ----------------------------"
apt-get install -y ntp
echo "---------------------------- Khoi dong lai NTP ----------------------------"
sleep 3
service ntp restart


echo "---------------------------- cai dat Messaging server cho ubuntu ----------------------------"
apt-get install -y rabbitmq-server
rabbitmqctl change_password guest $RABBIT_PASS
echo "---------------------------- Khoi dong lai may ----------------------------"
sleep 2
service rabbitmq-server restart
sleep 2
init 6 