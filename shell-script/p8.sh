echo -n "Enter a student name: "
read name
echo -n "Enter $name subject1 mark: "
read s1
echo -n "Enter $name subject2 mark: "
read s2
echo -n "Enter $name subject3 mark: "
read s3

total=`expr $s1 + $s2 + $s3`
avg=`echo "scale=3;$total/3"|bc`

t=$((s1+s2+s3))

echo "
========================
Name	:	$name
------------------------
S1	:	$s1
S2	:	$s2
S3	:	$s3
------------------------
Total	:	$total
Total	:	$t
------------------------
Average	:	$avg
========================"
