#!/bin/bash
#
# Do some nfs cleanup...
# M. Dunning 6/21/13

args="[hourly | --daily | --weekly]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -gt 1 ]; then
    show_usage
    exit 1
fi

logDir=/nfs/slac/g/nlcta/u01/nlcta/computing/logs/nfsCleanup
logFile=$logDir/nfsCleanup.txt
tfEsb=/nfs/slac/g/testfac_esb
tfEsa=/nfs/slac/g/testfac_esa
tfAsta=/nfs/slac/g/testfac_asta
tfLog=/nfs/slac/g/testfac_log
nlcta=/nfs/slac/g/nlcta/u01
asta=/nfs/slac/g/asta
estb=/nfs/slac/g/estb
fileSize=+1G  # File size for search
usageLimit=90  # Usage limit notification point for filesystems, in percent
ageLimit=+90  # Age limit, in days


# set up email parameters
mailTo=mdunning
mailToAsta=mdunning,spw
mailFrom=nlctaAutobot
mailSubject="NFS Cleanup"

exec &> $logFile

echo "Script: $0"
echo "Run as a cron job on $HOSTNAME on `date`"
echo

# Define some functions ========================================
#===============================================================
# Search for files larger than $fileSize
function bigFileSearch {
    dirList="$tfEsb $tfEsa $tfAsta $tfLog"
    for dirs in $dirList; do
        echo "Searching $dirs for files larger than $fileSize..."
        find $dirs -type f -size $fileSize -exec ls -lh {} \; | awk '{ print $9 ": " $5 }' | sort -nrk 2,2
        echo
    done
}

# Do some cleanup
function fileCleanup {
    dirList="$tfEsb/nlcta/ /home/nlcta/"
    fileList="core."
    for dirs in $dirList; do
        for files in $fileList; do
            echo "Cleaning up $files* files in $dirs..."
            find $dirs -type f -name "$files*" -exec rm -vf {} \;
            echo
        done
    done
    echo
}

# Check filesystem usage
function filesystemUsage {
    echo "NFS filesystem use:"
    echo "`df -h $tfEsa $tfEsb $tfAsta $tfLog $nlcta $asta $estb`"
    echo
    echo
    dirList="$tfEsb $tfLog"
    for dirs in $dirList; do
        echo "Largest directories in $dirs"
        echo "`du -shc ${dirs}/* | sort -n | tail -10`"
        echo
    done
    echo
    echo
}

# Check $tfEsb usage
function tfUsage {
    tf_esb_use=`df -h $tfEsb | tr -s ' ' | cut -d ' ' -f 5  | tail -1 | sed 's/%//'`
    nlcta_use=`df -h $nlcta | tr -s ' ' | cut -d ' ' -f 5  | tail -1 | sed 's/%//'`
    asta_use=`df -h $asta | tr -s ' ' | cut -d ' ' -f 5  | tail -1 | sed 's/%//'`
    #useList="$tf_esb_use $nlcta_use $asta_use"
    #useList="tf_esb_use nlcta_use asta_use"
}

# Delete files older than $ageLimit 
function logCleanup {
    dirList="$tfEsb"
    fileList="log-*"
    for dirs in $dirList; do
        for files in $fileList; do
            echo "Cleaning up $files files in $dirs older than $ageLimit days..."
            find $dirs -type f -name "$files" -mtime $ageLimit -exec rm -f {} \;
        done
    done
    echo
}

#========================================================
startTime=`date +%s`
# Do common routines
#filesystemUsage


if [ "$1" = "--hourly" ]; then
    # Do routines & email if necessary
    tfUsage
    #endTime=`date +%s`
    #echo "It took $(($endTime - $startTime)) seconds to complete this..."
    if [ "$tf_esb_use" -gt "$usageLimit" ]; then
        if [ -s $logFile ]; then
            echo "`cat $logFile`" | mailx -s "$tfEsb usage ${tf_esb_use}%" -r $mailFrom $mailTo
        else
            echo "" | mailx -s "$tfEsb usage ${tf_esb_use}%" -r $mailFrom $mailTo
        fi    
    fi
    if [ "$nlcta_use" -gt "$usageLimit" ]; then
        if [ -s $logFile ]; then
            echo "`cat $logFile`" | mailx -s "$nlcta usage ${nlcta_use}%" -r $mailFrom $mailTo
        else
            echo "" | mailx -s "$nlcta usage ${nlcta_use}%" -r $mailFrom $mailTo
        fi    
    fi
    if [ "$asta_use" -gt "$usageLimit" ]; then
        if [ -s $logFile ]; then
            echo "`cat $logFile`" | mailx -s "$asta usage ${asta_use}%" -r $mailFrom $mailToAsta
        else
            echo "" | mailx -s "$asta usage ${asta_use}%" -r $mailFrom $mailTo
        fi    
    fi
elif [ "$1" = "--daily" ]; then
    # Do routines & email if necessary
    filesystemUsage
    tfUsage
    endTime=`date +%s`
    echo "It took $(($endTime - $startTime)) seconds to complete this..."
    if [ "$tf_esb_use" -gt "$usageLimit" ]; then
        if [ -s $logFile ]; then
            echo "`cat $logFile`" | mailx -s "$tfEsb usage ${tf_esb_use}%" -r $mailFrom $mailTo
        else
            echo "" | mailx -s "$tfEsb usage ${tf_esb_use}%" -r $mailFrom $mailTo
        fi    
    fi
    if [ "$nlcta_use" -gt "$usageLimit" ]; then
        if [ -s $logFile ]; then
            echo "`cat $logFile`" | mailx -s "$nlcta usage ${nlcta_use}%" -r $mailFrom $mailTo
        else
            echo "" | mailx -s "$nlcta usage ${nlcta_use}%" -r $mailFrom $mailTo
        fi    
    fi
    if [ "$asta_use" -gt "$usageLimit" ]; then
        if [ -s $logFile ]; then
            echo "`cat $logFile`" | mailx -s "$asta usage ${asta_use}%" -r $mailFrom $mailToAsta
        else
            echo "" | mailx -s "$asta usage ${asta_use}%" -r $mailFrom $mailTo
        fi    
    fi
elif [ "$1" = "--weekly" -o -z "$1" ]; then
    # Do routines & send a summary email with results
    filesystemUsage
    bigFileSearch
    fileCleanup
    logCleanup
    endTime=`date +%s`
    echo "It took $(($endTime - $startTime)) seconds to complete this..."
    if [ -s $logFile ]; then
        echo "`cat $logFile`" | mailx -s "$mailSubject" -r $mailFrom $mailTo
    fi
elif [ "$1" = "--test" ]; then
    # Do routines & send a summary email with results
    #filesystemUsage
    #bigFileSearch
    fileCleanup
    #logCleanup
    endTime=`date +%s`
    echo "It took $(($endTime - $startTime)) seconds to complete this..."
    if [ -s $logFile ]; then
        echo "`cat $logFile`" | mailx -s "$mailSubject" -r $mailFrom $mailTo
    fi
else
    echo "Invalid option: $1"
    show_usage
    exit 1
fi


exit 0

