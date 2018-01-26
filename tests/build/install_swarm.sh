#!/bin/bash

###### INIT DOCKER SWARM ################
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

