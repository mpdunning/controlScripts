#!/bin/bash
#
# backup-afs.sh
# backs up selected files on afs to nfs and writes a log file
# this is run as a cron job on ar-grover
# M. Dunning 2/12/12

args="--daily|--weekly|--monthly"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 1 ]; then
    show_usage
    exit 1
fi

if [ "$1" = "--daily" ]; then
    when=daily
elif [ "$1" = "--weekly" ]; then
    when=weekly
elif [ "$1" = "--monthly" ]; then
    when=monthly
else
    show_usage
    exit 1
fi

SCRIPT=/afs/slac/g/testfac/extras/scripts
scriptDir=$SCRIPT/backup/afs
dirList=$scriptDir/rsync-dir-list.txt
excludeList=$scriptDir/exclude-list.txt
backupDir=/nfs/slac/g/nlcta/u01/nlcta/backups/afs/$when
logDir=/nfs/slac/g/nlcta/u01/nlcta/backups/log

# set up email parameters
mailTo=mdunning
mailFrom=nlctaAutobot
mailSubject="afs backup error"

exec > $logDir/afs-$when.log
exec 2> $logDir/afs-$when.err
#####################################################################

echo "This script: $0"
echo "`date`"
echo "Backing up selected afs files to $backupDir"
echo "########################################################"
echo ""
echo ""

# If monthly, archive the previous backup first
if [ "$1" = "--monthly" ]; then
    tar -cvzf $backupDir/../archive/backup-afs-`date +"%Y%m%d"`.tar.gz $backupDir
fi

for line in $(cat $dirList | grep -v '#'); do
    #rsync -av --force --exclude-from=$excludeList $line $backupDir/`basename $line`/
    rsync -av --force --exclude-from=$excludeList $line $backupDir/`echo "$line" | tr '//' '_' | rev | cut -d '_' -f 1-3 | rev | sed 's/_\+$//'`/
done
####################################################################

# send an email if there are errors
if [ -s "$logDir/afs-$when.err" ]; then
    echo "`cat $logDir/afs-$when.err`" | mailx -s "$mailSubject" -r $mailFrom $mailTo
fi

exit 0
