#!/bin/bash


name=nlctaTest
title="test with attachment"
program=152
timestamp=`date +%Y/%m/%d" "%H:%M:%S`
priority=NORMAL
#osUser=apache
osUser=nlcta
hostname=mccelog
logbook=nlcta
text="this is a test to see if we can do autoelogs with attachments..."
logUser=acc_status
tmpDir=/nfs/slac/g/nlcta/u01/nlcta/elog/test
elogFileName=$tmpDir/`date +%Y%m%d_%H%M%S`_$name.xml
attach1=$tmpDir/test.png
elogAttachName=`date +%Y%m%d_%H%M%S`_$name.attach_1.png
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
echo "    <attachment name=\"Figure1\" type=\"image/png\">$elogAttachName</attachment>" >> $elogFileName
echo "</log_entry>"                                 >> $elogFileName

if [ -d "$elogDir" ]; then
    cp -v $elogFileName $elogDir
    cp -v $attach1 $elogDir/$elogAttachName
fi

