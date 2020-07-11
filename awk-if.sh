BEGIN{
FS=","
}
{
if(NR>3 && NR<7){
	print NR, $0
}
}
END{
print "-------Thank You-----"
}
