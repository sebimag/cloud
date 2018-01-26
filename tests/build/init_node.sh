#! /bin/bash
sudo su

apt-get update -y
apt-get upgrade -y 

apt-get install -y libltdl7

wget https://download.docker.com/linux/ubuntu/dists/zesty/pool/stable/amd64/docker-ce_17.12.0~ce-0~ubuntu_amd64.deb

yes | dpkg -i docker-ce_17.12.0~ce-0~ubuntu_amd64.deb
