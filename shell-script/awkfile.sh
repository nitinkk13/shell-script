#!/bin/bash
echo "script section begin"
awk
BEGIN{
print "Slaes emp details"
print "------------------"
FS=","
OFS="\t"
}
/sales/{
print NR,$2,$NF,$NF*0.20
}
END{
print "-------------Thank You-----------"
} emp.csv
