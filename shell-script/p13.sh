echo -n "Enter a N value: "
read n
if [ $n -eq 100 ];then
	echo "True1"
elif [ $n -gt 500 ];then
	echo "True2"
elif [ $n -lt 300 ];then
	echo "True3"
elif [ "abc" == "abc" ];then
	echo "True4"
fi
