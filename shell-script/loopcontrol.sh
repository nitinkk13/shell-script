#!/bin/bash

a=10

until [ $a -lt 10 ]; do
  #statement
  echo $a
  if [ $a -eq 100 ]
  then
     break
  fi
  a=`expr $a + 1`
done
