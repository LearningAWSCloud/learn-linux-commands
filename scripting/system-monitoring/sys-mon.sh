#!/bin/bash
IFS="
"
THRESHOLD=30
FILESIZE="70M"

function cpu_usage_processes {
        top_out=`top -b -n 1 -i | grep "^\s\+[0-9]"`
        for line in $top_out; do
            cpu_usage=`echo $line | awk '{print $9}'`
            cpu_int=`printf '%.0f\n' $cpu_usage`
            if [ $cpu_int -gt $THRESHOLD ]; then
                pid=`echo $line | awk '{print $1}'`
                echo "Listing process id : ${pid} as threshold reaches $cpu_usage"
                ps -eaf | grep $pid | grep -v grep
            fi
        done
}

function list_bigger_files {
    file_out=`find $1 -type f -size +$FILESIZE | wc -l`
    if [ $file_out -gt 0 ]; then
        echo "Below files are greater than $FILESIZE under $1"
        find $1 -type f -size +$FILESIZE | xargs ls -lh
    else
        echo "$1 directory don't have any files greater than $FILESIZE"
    fi
}

function http_server_running {
    http=`netstat -altnp | grep LISTEN | grep :80 | wc -l`
    if [ $http -gt 0 ]; then
        echo "Apache2 is running"
    else
        echo "Apache2 is not running"
    fi
}

function memory_usage_in_percentage {
    mem_use=`free -m | awk '/^Mem:/ {printf "%d\n", ($3/$2)*100}'`
    if [ $mem_use -lt 50 ]; then
        echo -e "$(tput setaf 2) Memory is Stable at $mem_use $(tput sgr0)"
    else
        echo -e "$(tput setaf 1) Memory is not Stable at $mem_use $(tput sgr0)"
    fi
}


# cpu_usage_processes
# list_bigger_files "/home"
# list_bigger_files "/var"
# http_server_running
memory_usage_in_percentage
