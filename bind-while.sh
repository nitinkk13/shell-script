while read var
do
	if [[ $var =~ ^$ ]]; then
		continue # Empty Line
	else
		echo $var # Nonwmpty Line
	fi
done<process.log

echo -e "\n\n"

while read var
do
        if ! [[ $var =~ ^$ ]]; then
                echo $var # Nonwmpty Line
        fi
done<process.log
