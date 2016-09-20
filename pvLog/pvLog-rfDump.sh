#!/bin/bash

args="PV_PREFIX INPUT_NUMBER"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 2 ]; then
    show_usage
    exit 1
fi

pvPrefix=$1
inputNum=$2

monitorPv=`caget -t $pvPrefix:INP${inputNum}.INP | cut -d " " -f 1`
priorityPv=GUN:AS01:1:GN1:RWAV.PRIO
echo "$monitorPv"
monitorTime=`caget -t $pvPrefix:INP${inputNum}:TOTALTIME`
outDir=$NFSHOME/pvLog/`date +%Y%m%d`
outFile=$outDir/pvLog-`date +%Y%m%d_%H%M%S`.dat

if [ ! -d $outDir ]; then
    mkdir -p $outDir
fi

caput -S $pvPrefix:INP${inputNum}:MSG "Dumping data.........."
caput $priorityPv HIGH
sleep 0.5
timeout $monitorTime camonitor $monitorPv &> $outFile
sleep 0.5
caput $priorityPv LOW
caput -S $pvPrefix:INP${inputNum}:MSG "Data dumped"
caput -S $pvPrefix:INP${inputNum}:FILENAME "$outFile"

exit 0
