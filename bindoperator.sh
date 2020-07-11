read -p "Enter a URL: " url

if [[ $url =~ ^https.*(org$|com$) ]];then
	echo "matched url"
	# wget $url
else
	echo "invalid url"
fi
