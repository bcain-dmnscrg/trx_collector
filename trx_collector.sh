#!/bin/bash

set -e

if [ "$#" -ne 3 ]; then echo "Usage: $0 filename 'start_timestamp' 'end_timestamp' - timestamps can be in any form 'date' accepts as valid"; fi

filename=$1
start_time=$2
end_time=$3

start_epoch=`date -d "$start_time" "+%s"`
end_epoch=`date -d "$end_time" "+%s"`

declare -A trxs
declare -a trx_order
last_date=''
regex="^T ([0-9]*/[0-9]*/[0-9]* [0-9][0-9]:[0-9][0-9]:[0-9][0-9])\.([0-9]*) ([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*):([0-9]*) .*\[AP\] (.*)"

echo >&2 "Searching for transactions at $start_time...."
while read line
do
    if [ ${line:0:1} != 'T' ]; then continue; fi
    [[ "$line" =~ $regex ]] && ts="${BASH_REMATCH[1]}" && frac="${BASH_REMATCH[2]}" && host="${BASH_REMATCH[3]}" && port="${BASH_REMATCH[4]}" && action="${BASH_REMATCH[5]}"
    trx_epoch=`date -d "$ts" "+%s"`
    if [[ $trx_epoch -lt $start_epoch ]]; then continue; fi
    if [[ $trx_epoch -ge $end_epoch ]]; then break; fi
    if [[ "$last_date" != "$ts" ]]; then last_date="$ts"; echo >&2 "Working on $ts"; fi
    key="$host:$port"
    trx_list=()
    if [ ${trxs[$key]+_} ]; then 
        trx_list=${trxs[$key]}
        trx_list+=$'\n'
    else
        trx_order+=("$key")
    fi
    trx="$ts.$frac $action"
    trx_list+="$trx"
    trxs[$key]=$trx_list
done < <(zcat "$filename")
echo >&2 "Processing transactions up to $end_time...."

for order_index in `seq 0 $((${#trx_order[@]} - 1))`
do
    key=${trx_order[$order_index]}
    ip=`echo $key | cut -f 1 -d ':'`
    host=`resolveip -s $ip`
    trx_list=${trxs[$key]}
    echo "-------------------------------------------------------------------------------------------------------------------------------"
    echo "trx source: $key ($host)"
    echo "-------------------------------------------------------------------------------------------------------------------------------"
    echo "$trx_list"
done
