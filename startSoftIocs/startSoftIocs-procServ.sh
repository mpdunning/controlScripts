#!/bin/bash
#
# Starts softIOCs and writes stdout and stderr to log files.
# This script reads $SETUP/procserv/table.txt and starts a soft IOC if the IOC entry has boot=1.
# Requirements:
# - "area" must exist in $IOCCOMMON
# - "logPath" must exist or log will be written to cwd 
# - "options" must be a list of commands or empty quotes
# - "IOCSERVER" must be defined (e.g. as an environment variable)
# md 2/4/14

args="{-s | -k | -l | -n} {nlcta | nlcam | asta | esa | cha}"

function show_usage {
    echo "Usage: $0 $args"
    echo "-s = start siocs with boot=1"
    echo "-k = kill all active siocs"
    echo "-l = list active siocs"
    echo "-n = dry run: print siocs with boot=1"
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
    logPath=/nfs/slac/g/testfac/esb/startIOClogs
    . /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null
    options="| grep -v adps"
    if [ "`hostname`" != "$IOCSERVER" ]; then
        echo "This script must be run on $IOCSERVER"
        exit 1
    fi
elif [ "$area" = "asta" ]; then
    logPath=/nfs/slac/g/testfac/asta/startIOClogs
    . /afs/slac/g/testfac/home/asta/setupASTA &> /dev/null
    options=""
    if [ "`hostname`" != "$IOCSERVER" ]; then
        echo "This script must be run on $IOCSERVER"
        exit 1
    fi
elif [ "$area" = "esa" ]; then
    logPath=/nfs/slac/g/testfac/esa/startIOClogs
    . /afs/slac/g/testfac/home/esa/setupESA &> /dev/null
    options=""
    IOCSERVER=ar-esaux6
    if [ "`hostname`" != "$IOCSERVER" ]; then
        echo "This script must be run on $IOCSERVER"
        exit 1
    fi
elif [ "$area" = "cha" ]; then
    logPath=/nfs/slac/g/testfac/esb/cha/startIOClogs
    . /afs/slac/g/testfac/home/cha/setupCHA &> /dev/null
    options=""
    IOCSERVER=esaanal2
    if [ "`hostname`" != "$IOCSERVER" ]; then
        echo "This script must be run on $IOCSERVER"
        exit 1
    fi
elif [ "$area" = "nlcam" ]; then
    area=nlcta
    logPath=/nfs/slac/g/testfac/esb/nlcta/startIOClogs
    . /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null
    options="| grep adps"
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
if [ -z "$logPath" ]; then
    logPath=.
elif [ ! -d "$logPath" ]; then
    mkdir -p $logPath
fi

# Start siocs, kill siocs, list active siocs, or print siocs to be started
if [ "$1" = "-s" ]; then
    # Write log files
    exec 1> $logPath/$area-`hostname`-`date +%Y%m%d.%H%M%S`.log
    exec 2> $logPath/$area-`hostname`-`date +%Y%m%d.%H%M%S`.err
    echo "STARTING SOFT IOCS ON `hostname`"
    echo "`date +%Y%m%d.%H%M%S`"
    echo "####################################################"
    echo ""
    while read line; do
        modLine="$line | grep -w $area | grep ioc | grep -v '#' $options | tr -s ' '"
        area2=`eval echo $modLine | cut -d " " -f 3`
        ioc=`eval echo $modLine | cut -d " " -f 1`
        bootFlag=`eval echo $modLine | cut -d " " -f 8`
        if [ -n "$ioc" -a "$bootFlag" = 1 -a "$area" = "$area2" ]; then
            $procServPath/iocControl -s $ioc
            sleep 0.2
        fi
    done < $procServPath/table.txt
elif [ "$1" = "-k" ]; then
    # Write log files
    exec 1> $logPath/$area-`hostname`-`date +%Y%m%d.%H%M%S`.log
    exec 2> $logPath/$area-`hostname`-`date +%Y%m%d.%H%M%S`.err
    echo "KILLING SOFT IOCS ON `hostname`"
    echo "`date +%Y%m%d.%H%M%S`"
    echo "####################################################"
    echo ""
    while read line; do
        modLine="$line | grep -w $area | grep ioc | grep -v '#' $options | tr -s ' '"
        area2=`eval echo $modLine | cut -d " " -f 3`
        ioc=`eval echo $modLine | cut -d " " -f 1`
        bootFlag=`eval echo $modLine | cut -d " " -f 8`
        if [ -n "$ioc" -a "$area" = "$area2" ]; then
            $scripts/iocKill $ioc
            sleep 1
        fi
    done < $procServPath/table.txt
elif [ "$1" = "-l" ]; then
    $procServPath/iocControl -l
elif [ "$1" = "-n" ]; then
    echo "Soft IOCs to be started on boot:"
    while read line; do
        modLine="$line | grep -w $area | grep ioc | grep -v '#' $options | tr -s ' '"
        area2=`eval echo $modLine | cut -d " " -f 3`
        ioc=`eval echo $modLine | cut -d " " -f 1`
        bootFlag=`eval echo $modLine | cut -d " " -f 8`
        if [ -n "$ioc" -a "$bootFlag" = 1 -a "$area" = "$area2" ]; then
            echo "$ioc"
        fi
    done < $procServPath/table.txt
elif [ "$1" = "-h" -o "$1" = "--help" ]; then
    show_usage
    exit 1
else
    echo "Invalid option $1"
    show_usage
    exit 1
fi

exit 0
