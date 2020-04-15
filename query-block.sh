#!/bin/bash

for i in {3000..3092}
do
	clif query block $i | jq .block.header.proposer_address
done
