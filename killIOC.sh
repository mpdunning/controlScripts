#!/bin/bash
#
# Kills or restarts a procserv ioc using telnet

args="{-k | -r} IOCNAME"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 2 ]; then
    show_usage
    exit 1
fi

procServPath=/afs/slac/g/testfac/setup/procserv
ioc=$2
port=`grep -w $ioc $procServPath/table.txt | tr -s " " | cut -d " " -f 7`
ctrlT=0024
ctrlX=0030
ctrlQ=0021
ctrlR=0022
sleep1=1
sleep2=5

if [ -z "`grep -w $ioc $procServPath/table.txt`" ]; then
    echo "Invalid ioc $ioc"
    exit 1
fi

if [ "`hostname`" != "$IOCSERVER" -a "`hostname`" != "$CAMSERVER" -a "`hostname`" != "ar-count" ]; then
    echo "Invalid host `hostname`"
    exit 1
fi

if [ "$1" = "-k" ]; then
    #sleep $sleep2
    ( echo -e \\$ctrlT; sleep $sleep1; echo -e \\$ctrlX; sleep $sleep1; echo -e \\$ctrlQ; sleep $sleep1 ) | telnet localhost $port 
elif [ "$1" = "-r" ]; then
    #sleep $sleep2
    ( echo -e \\$ctrlT; sleep $sleep1; echo -e \\$ctrlX; sleep $sleep2; echo -e \\$ctrlT; sleep $sleep1 ) | telnet localhost $port
else
    show_usage
    exit 1
fi
