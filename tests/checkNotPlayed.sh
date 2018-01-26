#!/bin/bash

for i in $(seq $2 $3)
do
       res=$( curl $1/user/$i) 
       if [[ $res != *"not_played"* ]]; then
                exit 1
       fi
done


wait
exit 0 
