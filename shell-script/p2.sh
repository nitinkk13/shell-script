Name=`whoami`
user_id=`id -u`
os=`uname`
os_version=`uname -r`
DIR=`pwd`
echo "
*********************System Information*******************

Login name: $Name
Login ID: $user_id
Working Kernel name: $os
Version: $os_version
Working directory Path: $DIR

**********************************************************"
