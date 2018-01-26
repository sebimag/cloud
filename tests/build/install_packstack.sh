#! /bin/bash


###########INSTALL PACKSTACK#########
controler=$1
startPool=$2
endPool=$3
install_packstack="apt-get update -y; apt-get upgrade -y;
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
neutron subnet-create --name public-subnet --enable_dhcp=False --allocation-pool=start=$startPool,end=$enPool --gateway=10.11.54.156 public 10.11.54.0/24;
neutron subnet-create --name private-subnet --enable-dhcp=False --allocation-pool=start=192.168.5.1,end=192.168.5.254 --gateway=192.168.5.1 private 192.168.5.0/24;
neutron router-create router --distributed False;
neutron router-gateway-set router public-subnet;
neutron router-inteface-add router private-subnet;"

scp ensimag-packstack.txt root@10.11.51.173:~/

ssh root@10.11.51.173 $install_packstack
