#!/bin/bash

# Description: substitutes all template variables in FILE and restarts docker compose with the generated file
# Usage: run.sh [FILE],
#        if FILE is not given, uses ./nginx.template.conf as the template file

input="$1"
if [[ -z "$1" ]]; then
    input="./nginx.template.conf"
fi

res="./nginx.conf"
cp "$input" "$res"

# $1 - a line containing "key=value" pair
# replaces all occurrences of "key" by "value" in $res file
substitute () {
    pair=$(echo "$1" | tr "=" "\n")
    local array
    for v in $pair; do
        array+=("$v")
    done
    sed -i "s/\${${array[0]}}/${array[1]}/g" "$res"
}

# reading $input file by lines
while read -r line; do
    if [[ -z "$line" ]]; then
        continue;
    fi
    substitute "$line"
done < .env

# restarting docker compose
docker compose down && docker compose up -d

