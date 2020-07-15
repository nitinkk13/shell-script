#!/bin/bash

echo "Enter student name: "
read student
echo "Enter $student marks."
echo "Enter english marks out of 100: "
read eng

echo "Entwr hindi marks out of 100: "
read hin

echo "Entwr math marks out of 100: "
read math

echo "Entwr physics marks out of 100: "
read phy

echo "Entwr chemistry marks out of 100: "
read chem

sum=$((eng+hin+math+phy+chem))

echo "Total marks of $student out of 500: $sum"

avg=$((sum/5))

echo "Average mark of $student is: $avg"
