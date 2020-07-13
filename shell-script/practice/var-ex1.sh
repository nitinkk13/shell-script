#!/bin/bash

echo -e "System Information: \n----------------------------------------------"
K=`uname`
KV=`uname -r`
S=$SHELL
SV=$BASH_VERSION
P=`pwd`
DATE=`date +%D`
name=`whoami`

echo "Working kernel name is: $K
$K Version is: $KV
Working shell name: $S
Shell Version is: $SV
Current working directory is: $P
Current Date is: $DATE
Current User is: $name"

echo "End of the script.."
