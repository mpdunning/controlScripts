#!/bin/bash
#
# saveRef.sh: saves a screenshot of a profile monitor image
# M. Dunning 3/18/13

args="[CAM PVPREFIX]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 1 ]; then
    show_usage
    exit 1
fi

today=`date +%Y%m%d`
now=`date +%Y%m%d_%H%M%S`
pvPrefix=$1
prof=`caget -t $pvPrefix:cam1:BI:NAME.DESC | cut -d " " -f 2`

imageDir=/nfs/slac/g/nlcta/u01/nlcta/profileMonitor/ref/$prof

if [ ! -d "$imageDir" ]; then
    mkdir -p $imageDir
fi

import -window $(xprop -root 32x '\t$0' _NET_ACTIVE_WINDOW | cut -f 2) $imageDir/$pvPrefix_$now.png


exit 0
