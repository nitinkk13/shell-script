#!/bin/bash

while read var
do
	if [ $1 == 'cmdArgs.sh' -o $2 == 'cmdArgs.sh' ]
	then
		echo "Commandline argument can not be same as script."
		break
	fi
		
	echo "$var"
done<$1>$2
