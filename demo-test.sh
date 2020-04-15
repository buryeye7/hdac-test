#!/bin/bash

if [ $# == 0 ]; then
	echo "Please input node name"
	exit 0
fi


PW=12345678
for i in {0..10000}
do
	expect -c "
	spawn clif hdac transfer-to friday1a7yztvaja027yhx3cyne2nlxw60060ucr2tgm7 $i 0.01 30000000 --from $1
	expect "N]:"
		send \"y\\r\"
	expect "\'$1\':"
		send \"$PW\\r\"
	expect eof 
	"
done
