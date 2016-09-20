#!/bin/bash
#
# Starts the java archive viewer for nlcta & esa 
# M. Dunning 1/23/14

args="[nlcta|esa] [config file]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -gt 2 ]; then
    show_usage
    exit 1
fi

viewer=/afs/slac/g/testfac/tools/archiveViewer/archiveviewer.jar

if [ "$1" = "--backup" ]; then
    url=http://ar-count/cgi-bin/ArchiveDataServer.cgi
else
    url=http://ar-slimey/cgi-bin/ArchiveDataServer.cgi
fi

if [ $# -eq 0 ]; then
    java -jar $viewer -u $url &> /dev/null &
elif [ $# -eq 1 ]; then
    if [ -f "$1" ]; then
        java -jar $viewer -u $url -f $1 &> /dev/null &
    else
        java -jar $viewer -u $url &> /dev/null &
    fi
elif [ $# -eq 2 ]; then
    if [ "$1" = "nlcta" ]; then
        configDir=/nfs/slac/g/nlcta/u01/nlcta/archiveViewer
    elif [ "$1" = "esa" ]; then
        configDir=.
    else
        configDir=.
    fi
    java -jar $viewer -u $url -f $configDir/$2 &> /dev/null &
else
    show_usage
    exit 1
fi



exit 0

