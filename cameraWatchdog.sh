#!/bin/bash
#
# cameraWatchdog.sh: checks if cameras are connected, and if not power cycles them 
# Designed to run as a cron job
# M. Dunning 5/5/16

args="[asta | esa | nlcta]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -gt 1 ]; then
    show_usage
    exit 1
fi

# Lists of camera PV prefixes for different areas
esaCamList="PS2 PS4 PS5"
#esaCamList="PS2 PS4 PS5 PS6"
astaCamList=""
nlctaCamList=""

if [ "$1" = "esa" ]; then
    camList=$esaCamList
    . /afs/slac/g/testfac/home/esa/setupESA &> /dev/null
elif [ "$1" = "asta" ]; then
    camList=$astaCamList
    . /afs/slac/g/testfac/home/asta/setupASTA &> /dev/null
elif [ "$1" = "nlcta" ]; then
    camList=$nlctaCamList
    . /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null
else
    show_usage
fi

logDir=$NFSHOME/profileMonitor/log
logFile=$logDir/cameraWatchdog.log

for cam in $camList; do
    connectPv=${cam}:cam1:AsynIO.CNCT
    if [ "`caget -t -n $connectPv`" = 0 ]; then
        echo "`date`: $cam disconnected, power cycling..." >> $logFile
        $SCRIPT/rebootCamera.sh $cam &> /dev/null
    fi
done



exit 0


