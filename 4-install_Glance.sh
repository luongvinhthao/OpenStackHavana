#!/bin/bash
source config.cnf
set -e


echo "---------------------------- Install_Glance ----------------------------"

apt-get install glance python-glanceclient -y 
if [ -f /etc/glance/glance-api.conf ]; then #check the file exist 
	#statements
	echo "back up file config"
	cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bak
	cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.bak
fi

echo "---------------------------- Edit glance-api.conf ----------------------------"
echo "Change sql connetction"
sed -i 's|sqlite:////var/lib/glance/glance.sqlite|mysql://glance:GLANCE_DBPASS@controller/glance|' /etc/glance/glance-api.conf
sleep 2
sed -i 's|GLANCE_DBPASS|'$GLANCE_DBPASS'|' /etc/glance/glance-api.conf
echo "Insert [keystone_authtoken]"

sed -i '/auth_host = 127.0.0.1/aauth_uri = http://controller:5000' /etc/glance/glance-api.conf
sed -i 's|auth_host = 127.0.0.1|auth_host = '$HOST_NAME'|' /etc/glance/glance-api.conf
sed -i 's|admin_tenant_name = %SERVICE_TENANT_NAME%|admin_tenant_name = '$SERVICE_TENANT_NAME'|'  /etc/glance/glance-api.conf
sed -i 's|admin_user = %SERVICE_USER%|admin_user = glance|' /etc/glance/glance-api.conf
sed -i 's|admin_password = %SERVICE_PASSWORD%|admin_password = '$GLANCE_PASS'|' /etc/glance/glance-api.conf

echo "Insert [paste_deploy]"

sed -i 's/#flavor=/flavor= keystone/' /etc/glance/glance-api.conf

echo "---------------------------- Edit glance-registry.conf ----------------------------"
echo "Change sql connetction"
sed -i 's|sqlite:////var/lib/glance/glance.sqlite|mysql://glance:GLANCE_DBPASS@controller/glance|g' /etc/glance/glance-registry.conf
sleep 2
sed -i 's|GLANCE_DBPASS|'$GLANCE_DBPASS'|g' /etc/glance/glance-registry.conf

echo "Insert [keystone_authtoken]"

sed -i '/auth_host = 127.0.0.1/aauth_uri = http://controller:5000' /etc/glance/glance-registry.conf
sed -i 's|auth_host = 127.0.0.1|auth_host = '$HOST_NAME'|' /etc/glance/glance-registry.conf
sed -i 's|admin_tenant_name = %SERVICE_TENANT_NAME%|admin_tenant_name = '$SERVICE_TENANT_NAME'|'  /etc/glance/glance-registry.conf
sed -i 's|admin_user = %SERVICE_USER%|admin_user = glance|' /etc/glance/glance-registry.conf
sed -i 's|admin_password = %SERVICE_PASSWORD%|admin_password = '$GLANCE_PASS'|' /etc/glance/glance-registry.conf
echo "Insert [paste_deploy]"
sed -i 's/#flavor=/flavor= keystone/' /etc/glance/glance-registry.conf


echo "---------------------------- Create table ----------------------------"
glance-manage db_sync
sleep 6 
echo "---------------------------- Restart Glance Service ----------------------------"
service glance-registry restart
sleep 3 
service glance-api restart
sleep 3 

echo "---------------------------- Finish ----------------------------"