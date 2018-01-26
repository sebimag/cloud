#!bin/bash

./checkWeb http://$1
./checkDB.sh http://$1:8080 1 10001
./b.sh http://$1:8082 1 10001
./checkNotPlayed.sh http://$1:8081 1 10001
./checkImageBefore.sh http://$1:8083 1 10001
./play.sh http://$1:8000/index.html 1 10001
./checkIsPlayed.sh http://$1:8081 1 10001 
./checkImageAfter.sh http://$1:8083 1 10001
