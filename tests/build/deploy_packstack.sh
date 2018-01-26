#! /bin/bash

###########DEPLOY PACKSTACK
script="apt-get update -y; apt-get upgrade -y;
systemctl disable firewalld
systemctl stop firewalld;
systemctl disable NetworkManager;
systemctl stop NetworkManager;
systemctl enable network;
systemctl start network;
yum install -y https://rdoproject.org/repos/rdo-release.rpm;
yum install -y centos-release-openstack-pike;
yum-config-manager --enable openstack-pike;
yum update -y;
yum install -y openstack-packstack;
packstack --answer-file=ensimag-packstack.txt;
source ~/.bashrc;
neutron net-create public --router:external --provider:network_type vlan --provider:physical_network extnet --provider:segmentation_id 2232;
neutron subnet-create --name public-subnet --enable_dhcp=False --allocation-pool=start=10.11.54.150,end=10.11.54.169 --gateway=10.11.54.156 public 10.11.54.0/24;
neutron subnet-create --name private-subnet --enable-dhcp=False --allocation-pool=start=192.168.5.1/24,end=192.168.5.254 --gateway=192.168.5.1 private 192.168.5.0/24;
neutron router-create router --distributed False;
neutron router-gateway-set router public-subnet;
neutron router-inteface-add router private-subnet;

mkdir /tmp/images;
wget -P /tmp/images http://old-releases.ubuntu.com/releases/17.04/ubuntu-17.04-server-amd64.iso ;
glance image-create --name 'zesty' --is-public true --disk-format qcow2 --container-format bare --file /tmp/images/ubuntu-17.04-server-amd64.iso;
ssh-keygen -t rsa -N '' -f 'id_rsa';
source creds;
nova keypair-add --pub-key ~/.ssh/id_rsa.pub key1;
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0;
nova secgroup-add-rule default tcp 80 80 0.0.0.0/0;
nova secgroup-add-rule default tcp 443 443 0.0.0.0/0;
nova secgroup-add-rule default tcp 2377 2377 0.0.0.0/0;
nova secgroup-add-rule default tcp 7946 7946 0.0.0.0/0;
nova secgroup-add-rule default udp 4789 4789 0.0.0.0/0;
nova secgroup-add-rule default udp 7946 7946 0.0.0.0/0;

source keystonerc_admin
NET_ID=$(neutron net-list | awk '/ private-subnet / { print $2 }');
nova boot --flavor m1.tiny --image zesty --nic net-id=$NET_ID --security-group default --key-name key1 --user-data init_node.sh instance-web;
nova boot --flavor m1.tiny --image zesty --nic net-id=$NET_ID --security-group default --key-name key1 --user-data init_node.sh instance-p;
nova boot --flavor m1.tiny --image zesty --nic net-id=$NET_ID --security-group default --key-name key1 --user-data init_node.sh instance-b;
nova boot --flavor m1.tiny --image zesty --nic net-id=$NET_ID --security-group default --key-name key1 --user-data init_node.sh instanceredis;
nova boot --flavor m1.tiny --image zesty --nic net-id=$NET_ID --security-group default --key-name key1 --user-data init_node.sh instancemariadb;
neutron floatingip-create public-subnet;
nova floating-ip-associate instance-web 10.11.54.153
"

scp ensimag-packstack.txt root@10.11.51.173:~/

ssh root@10.11.51.173 $script


#############INIT DOCKER SWARM
init_swarm="source keystonerc_admin;
ipInstanceB=nova list | grep instance-b | awk '{ split($12, v, "="); print v[2]}';
ipInstanceP=nova list | grep instance-p | awk '{ split($12, v, "="); print v[2]}';
ipInstanceRedis=nova list | grep instanceredis | awk '{ split($12, v, "="); print v[2]}';
ipInstanceMariaDb=nova list | grep instancemariadb | awk '{ split($12, v, "="); print v[2]}';
ipInstanceWeb_tmp=nova list | grep instance-web | awk '{ split($12, v, "="); print v[2]}';
ipInstanceWeb='${ipInstanceWeb_tmp%?}';
swarm_manager='docker swarm init --advertise-addr $ipInstanceWeb';
swarm_worker='docker swarm join --token  $token $ipInstanceWeb:2377';
ssh root@$ipInstanceWeb swarm_manager;
ssh root@$ipInstanceB swarm_worker;
ssh root@$ipInstanceP swarm_worker;
ssh root@$ipInstanceRedis swarm_worker;
ssh root@$ipInstanceMariaDb swarm_worker;
ssh root@$ipInstanceWeb 'git clone https://github.com/sebimag/cloud.git; cd cloud; ./docker_services.sh';"

ssh root@10.11.54.173 $init_swarm
