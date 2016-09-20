#!/bin/bash
#
# alarm-laserChillers.sh: A script (designed to run as a cron job) that momitors the alarm states of the laser chillers and alerts people via email. 
#
# M. Dunning 2/23/14

# Source the nlcta epics environment setup script
. /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null 

# Log file
now=`date +%Y%m%d.%H%M%S`
logPath=/nfs/slac/g/nlcta/u01/nlcta/alarm
logFile=$logPath/alarm-laserChillers-$now.log

if [ ! -d "$logPath" ]; then
    mkdir -p $logPath
fi

# Email parameters
#mailTo=mdunning,igorm106,wpolzin1
#mailTo=mdunning
mailTo=mdunning,igorm106
mailFrom=nlctaAlarmAutobot
mailSubject="Laser Chiller Alarm"
email=0

# Postscript for email
message2="
...
To Troubleshoot: There *may* be an attached image.
Or view the archived data from an NLCTA linux host with this command: 
/afs/slac/g/testfac/extras/scripts/startArchiveViewer.sh nlcta nlctaLaserChillers.xml
...
...
This email was auto-generated as a cron job running on $HOSTNAME
"

# List of pvs to monitor; must have existing alarm records 
pv1=ESB:CHILLER:REGEN1:FLOW   # Reg1 chiller
pv2=ESB:CHILLER:REGEN2:FLOW   # Reg2 chiller 
pv3=ESB:CHILLER:REGEN3:FLOW   # Reg3 chiller
pv4=ESB:CHILLER:OSCILLATOR:FLOW   # Osc chiller 
pv5=ESB:LSR_ROOM:TEMP:REGEN1_H2O  # Reg1 water temp
pv6=ESB:LSR_ROOM:TEMP:OSC_H2O  # Osc water temp
pv7=ESB:CHILLER:OSCILLATOR:STATUS:SUMMARY  # Osc chiller status bit; 1=OK, 0=Fail
pv8=ESB:CHILLER:OSCILLATOR:TEMP:SUMMARY  # Osc chiller temp status bit; 1=OK, 0=Fail

# Loop over PVs and scan for alarms
for pv in $pv{1..6}; do 
    pvVal=`caget -t $pv`
    pvSevr=`caget -t $pv.SEVR`
    pvUnits=`caget -t $pv.EGU`
    pvDesc=`caget -t $pv.DESC`
    message1="Alarm: `date` -- $pvDesc ($pv) -- $pvSevr -- Value: $pvVal $pvUnits"
    if [ "$pvSevr" = "MAJOR" -o "$pvSevr" = "MINOR" ]; then
        echo "$message1" >> $logFile
        echo "$message2" >> $logFile
        email=1
    fi
done
unset pv
for pv in $pv{7..8}; do 
    pvVal=`caget -t $pv`
    pvSevr=`caget -t $pv.SEVR`
    pvDesc=`caget -t $pv.DESC`
    message1="Alarm: `date` -- $pvDesc ($pv) -- $pvSevr -- Value: $pvVal"
    if [ "$pvVal" = "0" ]; then
        echo "$message1" >> $logFile
        echo "$message2" >> $logFile
        email=1
    fi
done
    
# Grab an image file from the archiver to attach
archPath=/afs/slac/g/testfac/tools/archiveViewer/archiveviewer.jar
archConfigFile=/nfs/slac/g/nlcta/u01/nlcta/archiveViewer/nlctaLaserChillers.xml
archServer=http://$ARCHIVESERVER/cgi-bin/ArchiveDataServer.cgi
imageFile=$logPath/alarm-laserChillers-$now.png

# Send email if there's an alarm
if [ "$email" -eq 1 ]; then
    java -jar $archPath -nogui -u $archServer -f $archConfigFile -image $imageFile -quit &> /dev/null
    if [ -f "$imageFile" ]; then
        cat $logFile | mailx -s "$mailSubject" -r $mailFrom -a $imageFile $mailTo
    else
        cat $logFile | mailx -s "$mailSubject" -r $mailFrom $mailTo
    fi
fi

exit 0


