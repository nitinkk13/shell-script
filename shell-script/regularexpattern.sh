read -p "Enter a item number: " ino

echo $ino|grep -q "^[A-E][0-9][0-9][0-9]$"
if [ $? -ne 0 ];then
	echo "Sorry invalid format."
	exit
fi

read -p "Enter a item name: " iname

echo $iname|grep -q "^[A-E][a-z][a-z][a-z]$"
if [ $? -ne 0 ];then
        echo "Sorry invalid item name."
        exit
fi

echo -e "Item Number: $ino\t\t Item Name: $iname"
