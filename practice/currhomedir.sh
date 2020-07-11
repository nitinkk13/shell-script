#!/bin/bash

currdir=`pwd`

if test $currdir != $HOME
then
  echo "Your home directory is not the same as your present working directory."
else
  echo "$HOME is your current home directory."
fi
