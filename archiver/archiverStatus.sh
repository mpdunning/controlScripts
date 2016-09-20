#!/bin/bash
# Checks archiver status in various ways and generates a report
# Designed to be run as a daily cron job by root on the archiver machine.
#

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

#. /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null

# Archiver root
chanArch=/opt/chanarch

# Email parameters
mailTo=mdunning
mailFrom=root

# Redirect stdout & stderr to log files
logFile=$chanArch/archiverStatus.log
errFile=$chanArch/archiverStatus.err
exec > $logFile
exec 2> $errFile

# Generate report
echo "Channel Archiver Status Report"
echo "Run as `whoami` on `hostname` at `date +%Y%m%d.%H%M%S`"
echo "############################################################"
echo "############################################################"
echo ""

cd $chanArch

echo "Daemon Status:"
scripts/daemon_info.pl
echo "############################################################"
echo ""

scripts/make_archive_infofile.pl
echo "############################################################"
echo ""

if [ "`hostname`" = "ar-slimey" -o "`hostname`" = "ar-count" ]; then
    du -h --max-depth=1 /data
else
    scripts/show_sizes.pl
fi
echo "############################################################"
echo ""

echo "Engine Versions:"
scripts/engine_versions.pl
echo "############################################################"
echo ""

scripts/engine_write_durations.pl
echo "############################################################"
echo ""

echo "Files modified in the last 12 hours:"
find $chanarch -mmin -720 -type f -exec ls -lt {} \;
echo "############################################################"
echo ""

# Send an email if there are errors or if --email option
if [ -s "$errFile" ]; then
    echo "`cat $errFile`" | mailx -s "Archiver Error - `hostname`" -r $mailFrom $mailTo
elif [ -n "`grep down $logFile`" ]; then
    echo "`cat $logFile`" | mailx -s "Archiver Error - `hostname`" -r $mailFrom $mailTo 
elif [ "$1" = "--email" ]; then
    echo "`cat $logFile`" | mailx -s "Archiver Report" -r $mailFrom $mailTo 
fi


exit 0
