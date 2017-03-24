#!/bin/bash

# Generate a token there: https://github.com/settings/tokens
TOKEN=$1
TOKEN_ARGS=""

if [[ -n "${TOKEN}" ]]; then
    TOKEN_ARGS="-H \"Authorization: token $TOKEN\""
fi

# Get the list of OpenXT repos
repos=`curl ${TOKEN_ARGS} -s "https://api.github.com/users/openxt/repos?per_page=100" | jq '.[].name' | cut -d '"' -f 2`

for i in $repos;
do
	echo $i
done
