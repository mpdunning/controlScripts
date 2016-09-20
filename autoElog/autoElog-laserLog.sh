#!/bin/bash

oscPwr=`caget -t ESB:LSR:LOG01:OSC:PWR`
oscWl=`caget -t ESB:LSR:LOG01:OSC:WL` 
oscBw=`caget -t ESB:LSR:LOG01:OSC:BW`
reg1Pwr=`caget -t ESB:LSR:LOG01:REG1:PWR`
reg2Pwr=`caget -t ESB:LSR:LOG01:REG2:PWR`
reg3Pwr=`caget -t ESB:LSR:LOG01:REG3:PWR`
cmt=`caget -t ESB:LSR:LOG01:COMMENT`
author=`caget -t ESB:LSR:LOG01:AUTHOR`

name=nlctaLaserLog
title="Laser Maintenance Log"
program=152
timestamp=`date +%Y/%m/%d" "%H:%M:%S`
priority=NORMAL
#osUser=apache
osUser=nlcta
hostname=mccelog
logbook=nlcta-laser
text="osc power= $oscPwr mW, osc cwl= $oscWl nm, osc bandwidth= $oscBw nm, regen1 power= $reg1Pwr mW, regen2 power= $reg2Pwr mW, regen3 power= $reg3Pwr mW.  Comment: $cmt.  Entered by $author"
logUser=acc_status
tmpDir=/nfs/slac/g/nlcta/u01/nlcta/elog/laserLog
if [ ! -d "$tmpDir" ]; then
    mkdir -p $tmpDir
fi
elogFileName=$tmpDir/`date +%Y%m%d_%H%M%S`_$name.xml
elogDir=/nfs/slac/g/cd/mccelog/logxml/new

# Add XML Tags 
echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>"  > $elogFileName
echo "<log_entry type=\"LOGENTRY\">"                      >> $elogFileName
echo "    <title><![CDATA[$title]]></title>"                      >> $elogFileName
echo "    <program>$program</program>"                >> $elogFileName
echo "    <timestamp>$timestamp</timestamp>"          >> $elogFileName
echo "    <priority>$priority</priority>"             >> $elogFileName
echo "    <os_user>$osUser</os_user>"                 >> $elogFileName
echo "    <hostname>$hostname</hostname>"             >> $elogFileName
echo "    <text type=\"text/plain\"><![CDATA[$text]]></text>"      >> $elogFileName
echo "    <logbook>$logbook</logbook>"                >> $elogFileName
echo "    <log_user>$logUser</log_user>"              >> $elogFileName
echo "</log_entry>"                                 >> $elogFileName

if [ -d "$elogDir" ]; then
    cp -v $elogFileName $elogDir
fi

