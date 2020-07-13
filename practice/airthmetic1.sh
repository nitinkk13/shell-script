#!/bin/bash

echo "Enter the two values for A and B."

read A
read B

Sum=$((A+B))
Sub=$((A-B))

echo "Addition = $Sum"
echo "Substraction = $Sub"
