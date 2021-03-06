#!/bin/bash
source config.cnf
set -e

echo "---------------------------- Install_nova_compute ----------------------------"
apt-get install -y nova-compute-kvm python-guestfs python-mysqldb nova-network nova-api-metadata
dpkg-statoverride  --update --add root root 0644 /boot/vmlinuz-$(uname -r)
if [ ! -f /etc/kernel/postinst.d/statoverride ]; then
	mkdir /etc/kernel/postinst.d/statoverride
fi
cat << EOF >/etc/kernel/postinst.d/statoverride
#!/bin/sh
version="$1"
# passing the kernel version is required
[ -z "${version}" ] && exit 0
dpkg-statoverride --update --add root root 0644 /boot/vmlinuz-${version}
EOF

chmod +x /etc/kernel/postinst.d/statoverride

if [[ ! /etc/nova/nova.conf.bak ]]; then
	#statements
	cp /etc/nova/nova.conf /etc/nova/nova.conf.bak
fi
echo "---------------------------- Edit /etc/nova/nova.conf ----------------------------"
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

# storage
#volume_driver=nova.volume.driver.ISCSIDriver
#enabled_apis=ec2,osapi_compute,metadata
#volume_api_class=nova.volume.cinder.API
#iscsi_helper=tgtadm


#Rabbit
auth_strategy=keystone
rpc_backend = nova.rpc.impl_kombu
rabbit_host = controller
rabbit_password = openstack

my_ip=172.22.22.181
vnc_enabled=True
vncserver_listen=0.0.0.0
vncserver_proxyclient_address=$HOST_IP
novncproxy_base_url=http://$HOST_IP:6080/vnc_auto.html

enabled_apis=metadata

glance_host=controller

# Networking Flat
network_manager=nova.network.manager.FlatDHCPManager
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
network_size=254
allow_same_net_traffic=False
multi_host=True
send_arp_for_ha=True
share_dhcp_address=True
force_dhcp_release=True
flat_network_bridge=br100
flat_interface=eth0
public_interface=eth0

libvirt_type=qemu

# auto assign ip floating
#       default_floating_pool=Public
#floating_range = 172.22.22.192/29
#auto_assign_floating_ip=true
#quota_floating_ips = 5
[database]
# The SQLAlchemy connection string used to connect to the database
connection = mysql://nova:$NOVA_DBPASS@$HOST_NAME/nova

EOF

echo "---------------------------- Restart nova-network ----------------------------"
service nova-network restart
sleep 3
echo "---------------------------- Finish nova compute ----------------------------"