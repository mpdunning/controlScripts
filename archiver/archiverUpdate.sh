#!/bin/bash
# Updates archiver indices.
# Designed to be run as a daily cron job by root on the archiver machine.
# md

args="[--email]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -gt 1 ]; then
    show_usage
    exit 1
fi

if [ $# -eq 1 -a "$1" != "--email" ]; then
    show_usage
    exit 1
fi

# Need to source this so it knows the path to ArchiveIndexTool (or redefine PATH here)
. /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null

# Archiver root
chanArch=/opt/chanarch

# set up email parameters
mailTo=mdunning
mailFrom=root

# Redirect stdout & stderr to log files
# For some reason update_indices.pl like to write to stderr, so combine them for now
logFile=$chanArch/archiverUpdate.log
#errFile=$chanArch/archiverUpdate.err
exec &> $logFile
#exec 2> $errFile

echo "Channel Archiver Daily Update"
echo "Run as `whoami` on `hostname` at `date +%Y%m%d.%H%M%S`"
################################################################
echo ""

cd $chanArch
scripts/update_indices.pl
retval=$?
echo
echo "Return Value: $retval"
echo ""
echo ""
cat $chanArch/TF/ArchiveIndexTool.log

# This should return 1 if not OK, >1 if OK
nlines=`cat $chanArch/TF/ArchiveIndexTool.log | wc -l`

# Send an email if there are errors
if [ "$retval" -ne 0 -o "$nlines" -eq 1 ]; then
    echo "`cat $logFile`" | mailx -s "Archiver Update Error - `hostname`" -r $mailFrom $mailTo
fi
if [ "$1" = "--email" ]; then
    echo "`cat $logFile`" | mailx -s "Archiver Update" -r $mailFrom $mailTo
fi


exit 0
