#!/bin/bash

read -p "Enter a code: " code

case $code in

A|a) echo "Matched1" ;;

15) echo "Matched2" ;;

bash) echo "Matched3" ;;

*) echo "Invalid Code" ;;

esac
