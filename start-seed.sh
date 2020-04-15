#!/bin/bash

if [ $# == 0 ]; then
	echo "Please input node name"
	exit 0 
fi

SRC="go/src/github.com/hdac-io/friday"
rm -rf ~/.nodef/config
rm -rf ~/.nodef/data
rm -rf ~/.clif

tmp=$(ps -ef | grep grpc)
echo $tmp | while read line 
do 
	if [[ $line == *"CasperLabs"* ]];then
		target=$(echo $line |  awk -F' ' '{print $2}')
		kill -9 $target
		break
	fi
done

tmp=$(ps -ef | grep nodef)
echo $tmp | while read line 
do 
	if [[ $line == *"nodef"* ]];then
		target=$(echo $line |  awk -F' ' '{print $2}')
		kill -9 $target
		break
	fi
done

# run execution engine grpc server
./$SRC/CasperLabs/execution-engine/target/release/casperlabs-engine-grpc-server -t 8 $HOME/.casperlabs/.casper-node.sock&

# init node
nodef init $1 --chain-id testnet

# copy execution engine chain configurations
cp ./$SRC/x/executionlayer/resources/manifest.toml ~/.nodef/config

# create a wallet key

PW="12345678"

expect -c "
set timeout 3
spawn clif keys add $1
expect "disk:"
	send \"$PW\\r\"
expect "passphrase:"
	send \"$PW\\r\"
expect eof
"

# add genesis node
nodef add-genesis-account $(clif keys show $1 -a) 100000000stake
nodef add-el-genesis-account $1 "1000000000000000000000000000" "1000000000000000000"
nodef load-chainspec ~/.nodef/config/manifest.toml

# apply default clif configure
clif config chain-id testnet
clif config output json
clif config indent true
clif config trust-node true

# prepare genesis status
expect -c "
set timeout 3
spawn nodef gentx --name $1
expect "\'$1\':"
	send \"$PW\\r\"
expect eof
"

nodef collect-gentxs
nodef validate-genesis
