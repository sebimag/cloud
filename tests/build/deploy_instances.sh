#! /bin/bash

deploy_instance="mkdir /tmp/images;
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
nova floating-ip-associate instance-web 10.11.54.153;"

ssh root@10.11.51.173 $deploy_instance
