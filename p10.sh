echo -n "Enter a item number: "
read ino
if [ $ino -gt 500 ]
then
	echo -n "Enter a item name: "
	read iname
	if [ $iname == 'USB' ]
	then
		echo -e "Item number: $ino\t Item Name: $iname"
	else
		echo "Invaid item name"
	fi
else
	echo "Invalid item number"
fi
