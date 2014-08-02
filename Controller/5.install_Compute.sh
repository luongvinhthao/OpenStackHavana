#!/bin/bash
source config.cnf
set -e

echo "---------------------------- Install_Compute ----------------------------"
apt-get install -y nova-novncproxy novnc nova-api \
  nova-ajax-console-proxy nova-cert nova-conductor \
  nova-consoleauth nova-doc nova-scheduler \
  python-novaclient
if [ -f /etc/nova/nova.conf ]; then #check the file exist 
	#statements
	echo "back up file config"
	cp /etc/nova/nova.conf /etc/nova/nova.conf.bak
fi

echo "---------------------------- Edit nova.conf ----------------------------"
echo "Insert sql connetction"

cat << EOF > /etc/nova/nova.conf
[DEFAULT]
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
force_dhcp_release=True
iscsi_helper=tgtadm
libvirt_use_virtio_for_bridges=True
connection_type=libvirt
root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf
verbose=True
ec2_private_dns_show_ip=True
api_paste_config=/etc/nova/api-paste.ini
volumes_path=/var/lib/nova/volumes
enabled_apis=ec2,osapi_compute,metadata

auth_host = $HOST_NAME
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = nova
admin_password = $NOVA_PASS

my_ip=$HOST_IP
vncserver_listen=$HOST_IP
vncserver_proxyclient_address=$HOST_IP

rpc_backend = nova.rpc.impl_kombu
rabbit_host = $HOST_NAME
rabbit_password = $RABBIT_PASS

[database]
connection = mysql://nova:#NOVA_DBPASS@$NOVA_PASS/nova
EOF
