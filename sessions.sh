#!/bin/bash

set -e

host=''
start_set=0
start_time=""
end_time=""
regex="trx source:.*\((.*)\)"
declare -A hosts
declare -a host_order
while read line
do
    if [ ${line:0:3} = "trx" ]; then
        [[ "$line" =~ $regex ]] && host="${BASH_REMATCH[1]}"
        start_set=0
        start_time=""
        end_time=""
    elif [ $start_set -eq 1 ]; then
        end_time=`echo "$line" | cut -f 1 -d '.'`
    else
        start_time=`echo "$line" | cut -f 1 -d '.'`
        start_set=1
    fi
    if [[ "$end_time" != "" ]]; then
        conns='';
        if [ ${hosts[$host]+_} ]; then
            conns=${hosts[$host]}
            conns+=$'\n'
        else
            host_order+=("$host")
        fi
        conn="$host $start_time $end_time"
        conns+="$conn"
        hosts[$host]=$conns
    fi
done < <(grep -A 2 -B 2 'trx source' $1 | egrep 'trx|2015')

for host_index in `seq 0 $((${#host_order[@]} - 1))`
do
    host=${host_order[$host_index]}
    echo "${hosts[$host]}"
done
