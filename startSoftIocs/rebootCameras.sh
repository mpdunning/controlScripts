#!/bin/bash
#
# Power cycles cameras and reboots camera iocs
# md 2/4/14

args="{nlcta | esa}"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 1 ]; then
    show_usage
    exit 1
fi

area=$1
scripts=/afs/slac/g/testfac/extras/scripts
scriptPath=$scripts/startSoftIocs
procServPath=/afs/slac/g/testfac/setup/procserv

if [ "$area" = "nlcta" ]; then
    . /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null
    logPath=/nfs/slac/g/testfac/esb/nlcta/startIOClogs
    pduPrefix=ESB:ACSW
    camChar=`echo "sioc-esb-adps" | wc -c`
    options="grep adps"
    if [ "`hostname`" != "$CAMSERVER" ]; then
    #if [ "`hostname`" != "ar-grover" ]; then
        echo "This script must be run on $CAMSERVER"
        exit 1
    fi
elif [ "$area" = "esacam" ]; then
    #. /afs/slac/g/testfac/home/nlcta/setupNLCTA &> /dev/null
    logPath=/nfs/slac/g/testfac/esb/nlcta/startIOClogs
    pduPrefix=ESA:ACSW
    camChar=`echo "sioc-esa-adps" | wc -c`
    options="grep adps"
    if [ "`hostname`" != "$CAMSERVER" ]; then
        echo "This script must be run on $CAMSERVER"
        exit 1
    fi
else
    echo "Invalid area $area"
    show_usage
    exit 1
fi

# Write log files
exec 1> $logPath/$area-cameraReboot-`hostname`.log
exec 2> $logPath/$area-cameraReboot-`hostname`.err

echo "********************************************"
echo "Power cycling & rebooting cameras on `hostname`"
echo "`date +%Y%m%d.%H%M%S`"
echo "********************************************"
echo

# Power cycle cameras
while read line; do
    #echo "$line"
    modLine="$line | grep -w $area | grep sioc | grep -v '#' | $options | tr -s ' '"
    #echo "$modline"
    ioc=`eval echo $modLine | cut -d " " -f 1`
    bootFlag=`eval echo $modLine | cut -d " " -f 8`
    if [ -n "$ioc" -a "$bootFlag" = 1 ]; then
        cam=`echo "$ioc" | cut -c $camChar-` 
        pdu=`caget -t 13PS$cam:cam1:PDU`
        outlet=`caget -t 13PS$cam:cam1:OUTLET`
        if [ "$?" = 0 ]; then
            caput $pduPrefix$pdu:BO:REBOOT:$outlet 1
            sleep 10
            #echo "$pduPrefix$pdu:BO:REBOOT:$outlet 1"
        fi
    fi
done < $procServPath/table.txt

sleep 120

# Restart IOCs
while read line; do
    modLine="$line | grep -w $area | grep sioc | grep -v '#' | $options | tr -s ' '"
    ioc=`eval echo $modLine | cut -d " " -f 1`
    bootFlag=`eval echo $modLine | cut -d " " -f 8`
    if [ -n "$ioc" -a "$bootFlag" = 1 ]; then
        $scripts/iocRestartCamera.sh $ioc
        #echo "$ioc"
    fi
done < $procServPath/table.txt

echo "********************************************"
echo "Done"
echo "`date +%Y%m%d.%H%M%S`"
echo


exit 0
