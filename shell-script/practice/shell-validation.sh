#!/bin/bash

echo -n "Enter user name: "
read user


if [ $user == admin ]
	then
		echo -n "Enter shell name: "
		read shell

		if [ $shell == bash ]
			then
				echo -e "User name is $user and entered shell is $shell."
		fi
else
	echo "Entered user name is not admin."
fi
