#!/bin/bash
#
# Starts softIOCs and writes stdout and stderr to log files
# md 2/4/14

args="OPTION={-s,-k,-l} AREA={nlcta,nlctaCameras...}"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 2 ]; then
    show_usage
    exit 1
fi

procServPath=/afs/slac/g/testfac/setup/procserv
scripts=/afs/slac/g/testfac/extras/scripts
scriptPath=$scripts/startSoftIocs
area=$2

if [ "$area" = "nlcta" ]; then
    logPath=/nfs/slac/g/testfac/esb/nlcta/startIOClogs
    iocList=$scriptPath/softIocList-$area.txt
    . /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null
    if [ "`hostname`" != "$IOCSERVER" ]; then
        echo "This script must be run on $IOCSERVER"
        exit 1
    fi
elif [ "$area" = "nlctaCameras" ]; then
    logPath=/nfs/slac/g/testfac/esb/nlcta/startIOClogs
    iocList=$scriptPath/softIocList-$area.txt
    . /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null
    if [ "`hostname`" != "$CAMSERVER" ]; then
        echo "This script must be run on $CAMSERVER"
        exit 1
    fi
else
    echo "Invalid area $area"
    show_usage
    exit 1
fi

# Create log dir if it doesn't exist
if [ ! -d "$logPath" ]; then
    mkdir -p $logPath
fi

# If -l option, list active siocs
if [ "$1" = "-l" ]; then
    $procServPath/iocControl -l
    exit 0
fi

# Write log files
exec 1> $logPath/$area-`hostname`-`date +%Y%m%d.%H%M%S`.log
exec 2> $logPath/$area-`hostname`-`date +%Y%m%d.%H%M%S`.err

# Start or kill IOCs
if [ "$1" = "-s" ]; then
    echo "STARTING SOFT IOCS ON `hostname`"
    echo "`date +%Y%m%d.%H%M%S`"
    echo "####################################################"
    echo ""
    for line in `cat $iocList | grep -v "#"`; do
        $procServPath/iocControl -s $line
        sleep 2
    done
elif [ "$1" = "-k" ]; then
    echo "KILLING SOFT IOCS ON `hostname`"
    echo "`date +%Y%m%d.%H%M%S`"
    echo "####################################################"
    echo ""
    for line in `cat $iocList | grep -v "#"`; do
        $scripts/iocKill $line
        sleep 1
    done
else
    echo "Invalid option $1"
    show_usage
    exit 1
fi




exit 0
