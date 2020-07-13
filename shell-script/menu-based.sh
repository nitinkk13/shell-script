
while :
do
echo -n 
"***********System Info******************
*	1. Kernel Details		*
*	2. Login Shell Details		*
*	3. Current Process		*
*	4. Login Details		*
*	5. Mounted Filesystem		*
*	6. Exit from menu		*
*****************************************"

	read -p "Enter your choice: " choice

	case $choice in
		1) echo -e "Working Kernel name is: `uname` \t Version: `uname -r`";;
		2) echo "Login shell is: $SHELL";;
		3) echo -e "Current Process are: \n `ps -f`";;
		4) echo  "Login user details: `whoami`";;
		5) echo -e "Mounted filesystem: \n `df -hP`";;
		6) echo "Thank You";break;;
		*) echo "Invalid Choice"
	esac
done
