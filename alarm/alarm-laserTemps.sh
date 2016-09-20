#!/bin/bash
#
# alarm-laserTemps.sh: A script (designed to run as a cron job) that momitors the alarm states of the laser room thermocouples and alerts people via email. 
#
# M. Dunning 3/12/13

# Source the nlcta epics environment setup script
. /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null 

# Log file
now=`date +%Y%m%d.%H%M%S`
logPath=/nfs/slac/g/nlcta/u01/nlcta/alarm
if [ ! -d $logPath ]; then
    logPath=/tmp
fi
logFile=$logPath/alarm-laserTemp-$now.log
archPath=/afs/slac/g/testfac/tools/archiveViewer/archiveviewer.jar
archConfigFile=/nfs/slac/g/nlcta/u01/nlcta/archiveViewer/nlctaLaserThermocouples2.xml
if [ ! -f $archConfigFile ]; then
    if [ -f ~/nlctaLaserThermocouples3.xml ]; then
        archConfigFile=~/nlctaLaserThermocouples3.xml
    fi
fi
archServer=http://$ARCHIVESERVER/cgi-bin/ArchiveDataServer.cgi
imageFile=$logPath/alarm-laserTemp-$now.png

# Email parameters
#mailTo=mdunning,hast,keith.jobe,djm,igorm106,wpolzin1
#mailTo=mdunning
mailTo=mdunning,hast,keith.jobe,djm,igorm106
mailFrom=nlctaAlarmAutobot
mailSubject="Laser Temp Alarm"
email=0

# Postscript for email
message2="
...
To report:
Normal reporting through the Facilities service desk at x8901
After hours and weekend reporting:  Please page the HVAC group on their after-hours pager at 650-570-8811.
If you report, send an email and REPLY ALL to let them know it's been reported.
...
To troubleshoot: There *may* be an attached image.
Or view the archived data from any NLCTA linux host with this command: 
/afs/slac/g/testfac/extras/scripts/startArchiveViewer.sh nlcta nlctaLaserThermocouples2.xml
...
...
This email was auto-generated as a cron job running on $HOSTNAME
"

# List of pvs to monitor; must have existing alarm records 
pv1=ESB:LSR_ROOM:TEMP:AIR  # laser air temp
pv2=ESB:LSR_ROOM:TEMP:TABLE1  # laser table temp
pv3=ESB:LSR_ROOM:TEMP:ENCLOSURE_AIR  # laser enclosure temp
pv4=ESB:LSR_ROOM:TEMP:HVAC_DUCT  # laser hvac duct temp

# Loop over PVs and scan for alarms
for pv in $pv{1..4}; do 
    pvVal=`caget -t $pv`
    pvStat=`caget -t $pv.STAT`
    pvUnits=`caget -t $pv.EGU`
    pvDesc=`caget -t $pv.DESC`
    message1="Alarm: `date` -- $pvDesc ($pv) -- $pvStat -- Value: $pvVal $pvUnits"
    #echo "$pvVal"
    #echo "$pvStat"
    if [ "$pvStat" = "HIGH" -o "$pvStat" = "HIHI" -o "$pvStat" = "LOW" -o "$pvStat" = "LOLO" ]; then
        echo "$message1" >> $logFile
        email=1
    fi
done

echo "$message2" >> $logFile

# Send email if there's an alarm
if [ "$email" = 1 ]; then
    if [ -f $archConfigFile ]; then
        # Grab an image file from the archiver to attach
        java -jar $archPath -nogui -u $archServer -f $archConfigFile -image $imageFile -quit &> /dev/null
    fi
    if [ -f "$imageFile" ]; then
        cat $logFile | mailx -s "$mailSubject" -r $mailFrom -a $imageFile $mailTo
    else
        cat $logFile | mailx -s "$mailSubject" -r $mailFrom $mailTo
    fi
fi

exit 0


