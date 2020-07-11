#!/bin/bash

userName=`whoami`
loginID=`id -u`
kernelName=`uname`
kernelVersion=`uname -r`
workingDir=`pwd`

echo "Login Name: $userName"
echo "Login ID: $loginID"
echo "Kernel Name: $kernelName"
echo "Kernel Version: $kernelVersion"
echo "Current Working Directory: $workingDir"
