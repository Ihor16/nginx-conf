#!/bin/bash

# Description: substitutes all template variables in FILE and restarts docker compose with the generated file
# Usage: run.sh [FILE],
#        if FILE is not given, uses ./nginx.template.conf as the template file

input="$1"
if [[ -z "$1" ]]; then
    input="./nginx.template.conf"
fi

if [[ ! -e "$input" ]]; then
    echo "error: no such template file"
    exit 1
fi

res="./nginx.conf"
cp "$input" "$res"

# assigning word splitting by "="
IFS="="

# $1 - a line of "key=value" format
# replaces all occurrences of "key" by "value" in $res file
substitute () {
    # splitting $1 by $IFS and assigning the result to array $array
    read -r -a array <<< "$1"
    # trimming values
    local k=$(echo ${array[0]} | xargs)
    local v=$(echo ${array[1]} | xargs)
    sed -i "s/\${$k}/$v/g" "$res"
}

# reading $input file by lines
while read -r line; do
    if [[ -z "$line" ]]; then
        continue;
    fi
    substitute "$line"
done < .env

# restarting docker compose
docker container rm -f nginx-php-server-1
docker container rm -f nginx-node-1
docker compose down && docker compose up -d

