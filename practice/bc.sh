#!/bin/bash

<<multiline-comment
Line1
Line2
Line3
Line4
Line5

multiline-comment

echo "Enter two values for A and B"
read A
read B

echo `echo $A + $B|bc`
