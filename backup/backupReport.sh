#!/bin/bash
#
# backupReport.sh
#
# Emails a backup report 
# This should be run as a weekly cron job
# M. Dunning 12/1/2013  

args="[nlcta | asta]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -gt 1 ]; then
    show_usage
    exit 1
fi

if [ "$1" = "nlcta" ]; then
    backupDir=/nfs/slac/g/nlcta/u01/nlcta/backups
    mailTo=mdunning
    mailFrom=nlctaAutobot
    mailSubject="Backup report for $1"
elif [ "$1" = "asta" ]; then
    backupDir=/nfs/slac/g/asta/backup
    mailTo=mdunning
    mailFrom=nlctaAutobot
    mailSubject="Backup report for $1"
else
    backupDir=/nfs/slac/g/nlcta/u01/nlcta/backups
    mailTo=mdunning
    mailFrom=nlctaAutobot
    mailSubject="Backup report"
fi

logDir=$backupDir/log

# redirect output to log files
exec > $logDir/backupReport.log
exec 2> $logDir/backupReport.log

########################################################
# Creat backup report
echo "Backup report from $HOSTNAME"
echo ""
echo "Log files in $logDir:"
ls -lt $logDir/*.log
echo ""
echo "Error files in $logDir:"
ls -lt $logDir/*.err
echo ""
echo "###################################"
echo "Backup directory size:"
du -sh $backupDir
echo ""
echo "###################################"
echo "Filesystem use:"
df -h $backupDir
echo ""

########################################################
# send email with report
if [ -f "$logDir/backupReport.log" ]; then
    echo "`cat $logDir/backupReport.log`" | mailx -s "$mailSubject" -r $mailFrom $mailTo    
fi

exit 0
