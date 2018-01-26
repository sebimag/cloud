#!/bin/bash

isPresent=$( curl -o /dev/null --silent --head --write-out '%{http_code}' "$1")

if [[ $isPresent = *"000"* ]]; then
	exit 1
fi


exit 0
