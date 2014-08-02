#!/usr/bin/bash 
source config.cnf
set -e 

echo "---------------------------- Install Dashboard ----------------------------"
apt-get install -y memcached libapache2-mod-wsgi openstack-dashboard

apt-get remove --purge openstack-dashboard-ubuntu-theme



echo "---------------------------- Restart service ----------------------------"
service apache2 restart
service memcached restart