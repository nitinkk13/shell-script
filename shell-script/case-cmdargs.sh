#!/bin/bash

option="${1}"

case ${option} in
     -f) FILE="${2}"
     echo "File name is $FILE"
     ;;
     -d) DIR="${2}"
     echo "Directory name is $DIR"
     ;;
     *)
       echo "`basename ${0}`: [-f file] | [-d directroy]"
       exit 1
       ;;
esac
