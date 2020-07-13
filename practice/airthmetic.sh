#!/bin/bash

echo "Enter the two values for A and B: "

read A
read B

echo "Addition of A and B = `expr $A + $B`"
echo Substraction of A and B = `expr $A - $B`
echo Multiplication of A and B = `expr $A \* $B`
echo Division of A and B = `expr $A / $B` 
