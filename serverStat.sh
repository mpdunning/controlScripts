#!/bin/bash
#
# serverStat.sh: collects some diagnostic info and sends an email 
# M. Dunning 12/18/13

args="[nlcta | asta | esa]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -gt 1 ]; then
    show_usage
    exit 1
fi

# Check if nfs server is up
pingHost () {
    ping -c 1 $1 > /dev/null
    pingStat=$?
}

if [ "$1" = "asta" ]; then
    logDir=/nfs/slac/g/asta/computing/logs/serverStat
    . /afs/slac/g/testfac/home/asta/setupASTA &> /dev/null
    mailFrom=astaAutobot
elif [ "$1" = "esa" ]; then
    logDir=/nfs/slac/g/estb/computing/logs/serverStat
    . /afs/slac/g/testfac/home/esa/setupESA &> /dev/null
    mailFrom=esaAutobot
else
    logDir=/nfs/slac/g/nlcta/u01/nlcta/computing/logs/serverStat
    . /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null
    mailFrom=nlctaAutobot
fi

logFile=report-$HOSTNAME-`date +%Y%m%d`.log
mailTo=mdunning
mailSubject="Diagnostic report for $HOSTNAME"

# redirect output to log files
exec &> $logDir/$logFile

#pingHost $NFSSERVER1
pingStat=0

########################################################

# Create report
echo "Report for $HOSTNAME"
date
echo "Script: $0"
echo "Writing log file to $logDir/$logFile"
echo ""
echo ""
echo "######################################################################"
top -b -n 1 | head -2
echo ""
echo "######################################################################"
free -m
echo ""
echo "######################################################################"
echo "iostat:"
iostat -x 5 3
echo ""
echo "######################################################################"
echo "vmstat:"
vmstat
echo ""
echo "######################################################################"
echo "sar -n DEV 5 1:"
sar -n DEV 5 1
echo ""
echo "######################################################################"
echo "sar -n EDEV 5 1:"
sar -n EDEV 5 1
echo ""
echo "######################################################################"
if [ "$pingStat" -eq 0 ]; then
    df -h
else
    echo "***** WARNING: $NFSSERVER NOT RESPONDING TO PING *****"
fi
echo ""
echo "######################################################################"
echo "Top 15 processes"
ps -eo pcpu,pmem,pid,user,args | sort -k 1 -r | head -15 
echo ""
echo "######################################################################"
echo "mdadm raid devices:"
if [ -f /proc/mdstat ]; then
    cat /proc/mdstat
fi
echo "######################################################################"
niocs=$((`/afs/slac/g/testfac/setup/procserv/iocControl -l | wc -l` - 1)) 
echo "Active procServ IOCs: $niocs"
########################################################

# send email with report
if [ -f "$logDir/$logFile" ]; then
    echo "`cat $logDir/$logFile`" | mailx -s "$mailSubject" -r $mailFrom $mailTo
fi


exit 0
