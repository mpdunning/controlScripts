#!/bin/bash
#
# backup-home.sh
#
# Backs up home directory on $HOSTNAME to nfs and writes stdout and stderr to log files 
# This should be run as a nightly cron job
# Files/directories can be excluded by adding them to $scriptDir/exclude-list
# md 7/7/12: first version
# md 11/30/13: moved to run from afs instead of local disk  
# md 11/9/15: Added option for asta

args="[nlcta | asta]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -gt 1 ]; then
    show_usage
    exit 1
fi

if [ "$1" = "asta" ]; then
    backupDir=/nfs/slac/g/asta/backup
    mailTo=mdunning,spw
    mailTo=mdunning
    mailFrom=astaAutobot
    # Add other directories here for backup to $backupDir/data (must be in $HOME or symlinked to $HOME)
    dirList=""
elif [ "$1" = "nlcta" -o -z "$1" ]; then
    backupDir=/nfs/slac/g/nlcta/u01/nlcta/backups
    mailTo=mdunning
    mailFrom=nlctaAutobot
    # Add other directories here for backup to $backupDir/data (must be in $HOME or symlinked to $HOME)
    dirList="oam oam2014 echo phantom rattBoyz"
else
    show_usage
    exit 1
fi

SCRIPT=/afs/slac/g/testfac/extras/scripts
scriptDir=$SCRIPT/backup/home
logDir=$backupDir/log
mailSubject="$HOSTNAME backup error"

# redirect output to log files
exec > $logDir/$HOSTNAME.log
exec 2> $logDir/$HOSTNAME.err
########################################################

# $HOME backup routine
if [ ! -d "$backupDir/$HOSTNAME$HOME" ]; then
    mkdir -p $backupDir/$HOSTNAME$HOME
fi

echo "This script: $0"
echo "`date`"
echo "Backing up $HOSTNAME to $backupDir"
echo "########################################################"
echo ""
echo ""

if [ -f "$scriptDir/exclude-list" ]; then
    rsync -av --exclude-from $scriptDir/exclude-list $HOME/ $backupDir/$HOSTNAME$HOME/
else
    rsync -av $HOME/ $backupDir/$HOSTNAME$HOME/
fi
########################################################

# Back up archiver directory and data if it exists
if [ -d "/opt/chanarch" ]; then
    rsync -av /opt/chanarch --exclude-from $scriptDir/exclude-list $backupDir/$HOSTNAME/opt.chanarch
fi
if [ "$HOSTNAME" = "ar-slimey" ]; then
    rsync -av /data $backupDir/$HOSTNAME
fi
#########################################################

# Back up crontab and other config files
if [ "`crontab -l`" ]; then
    crontab -l > $backupDir/$HOSTNAME/crontab.txt
fi
if [ -f "/etc/exports" ]; then
    cat /etc/exports > $backupDir/$HOSTNAME/exports.txt
fi
if [ -f "/etc/fstab" ]; then
    cat /etc/fstab > $backupDir/$HOSTNAME/fstab.txt
fi
if [ -f "/etc/sysconfig/network-scripts/ifcfg-eth0" ]; then
    cat /etc/sysconfig/network-scripts/ifcfg-eth0 > $backupDir/$HOSTNAME/eth0.txt
fi
if [ -f "/etc/sysconfig/network-scripts/ifcfg-eth1" ]; then
    cat /etc/sysconfig/network-scripts/ifcfg-eth1 > $backupDir/$HOSTNAME/eth1.txt
fi
if [ -f "/etc/sysconfig/network-scripts/ifcfg-em1" ]; then
    cat /etc/sysconfig/network-scripts/ifcfg-em1 > $backupDir/$HOSTNAME/em1.txt
fi
if [ -f "/etc/sysconfig/network-scripts/ifcfg-p4p1" ]; then
    cat /etc/sysconfig/network-scripts/ifcfg-p4p1 > $backupDir/$HOSTNAME/p4p1.txt
fi
if [ -f "/etc/sysconfig/network-scripts/ifcfg-p1p1" ]; then
    cat /etc/sysconfig/network-scripts/ifcfg-p1p1 > $backupDir/$HOSTNAME/p1p1.txt
fi
if [ -f "/etc/auto.master" ]; then
    cat /etc/auto.master > $backupDir/$HOSTNAME/auto.master.txt
fi
if [ -f "/etc/auto.gfs" ]; then
    cat /etc/auto.gfs > $backupDir/$HOSTNAME/auto.gfs.txt
fi
########################################################

# Back up matlab GUIs, data, and configs for nlcta. Working versions of GUIs and configs should be kept on ar-grover.
if [ "$HOSTNAME" = "ar-grover" ]; then
    rsync -av $HOME/matlab/toolbox/ $backupDir/lclsGuis/current/toolbox/
    rsync -av $HOME/data/config/ $backupDir/lclsGuis/current/config/
fi
if [ "$1" = "nlcta" -a -d "$HOME/data/data/" ]; then
    rsync -av $HOME/data/data/ $backupDir/data/matlabData/
fi
########################################################

# Back up selected directories on each machine to common 'data' directory on nfs
for dirs in $dirList
    do
        if [ -d "$HOME/$dirs" ]; then
            rsync -av $HOME/$dirs/ $backupDir/data/$dirs/
        fi
    done
##########################################################

# send an email if there are errors
if [ -s $logDir/$HOSTNAME.err ]; then
    echo "`cat $logDir/$HOSTNAME.err`" | mailx -s "$mailSubject" -r $mailFrom $mailTo    
fi

exit 0
