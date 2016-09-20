#!/bin/bash

lsrPwr=`caget -t ESB:QE01:LSR:PWR`
charge=`caget -t ESB:QE01:BEAM:Q` 
qe=`caget -t ESB:QE01:QE:MAXE:TMP`

name=nlctaQE
title="QE Measurement"
program=152
timestamp=`date +%Y/%m/%d" "%H:%M:%S`
priority=NORMAL
#osUser=apache
osUser=nlcta
hostname=mccelog
logbook=nlcta
text="laser power= $lsrPwr mW, charge= $charge pC, qe=$qe"
logUser=acc_status
tmpDir=/nfs/slac/g/nlcta/u01/nlcta/elog/qe
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

