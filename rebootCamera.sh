#!/bin/bash
#
# Power cycles a camera and restores some settings
# M. Dunning 11/25/14

args="CAM_PVPREFIX"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 1 ]; then
    show_usage
    exit 1
fi

camPvPrefix=$1
if [ "`echo -n $camPvPrefix | tail -c 1`" = ":" ]; then
    camPvPrefix=`echo "$camPvPrefix" | sed s'/:$//'`
fi

pdu=`caget -t ${camPvPrefix}:cam1:PDU`
outlet=`caget -t ${camPvPrefix}:cam1:OUTLET`

if [ "$ACCELERATOR" = "nlcta" ]; then
    pduPV=ESB:ACSW${pdu}:BO:REBOOT:${outlet}
elif [ "$ACCELERATOR" = "asta" ]; then
    pduPV=ACSW:AS01:NW0${pdu}:${outlet}HARDRESET
elif [ "$ACCELERATOR" = "esa" ]; then
    pduPV=ESA:ACSW${pdu}:BO:REBOOT:${outlet}
else
    pduPV=ESB:ACSW${pdu}:BO:REBOOT:${outlet}
fi

#echo "${camPvPrefix} $pdu $outlet"

function reboot {
    caput $pduPV 1
    echo "Pausing for 30 sec...."
    sleep 30
    caput ${camPvPrefix}:cam1:BinX.PROC 1
    caput ${camPvPrefix}:cam1:BinY.PROC 1
    caput ${camPvPrefix}:cam1:TriggerMode.PROC 1
    caput ${camPvPrefix}:cam1:ArrayCallbacks 1
    caput ${camPvPrefix}:cam1:ArrayCallbacks.PROC 1
    caput ${camPvPrefix}:cam1:Gain.PROC 1
    caput ${camPvPrefix}:cam1:AcquireTime.PROC 1
    caput ${camPvPrefix}:cam1:AcquirePeriod.PROC 1
    echo "Pausing for 30 sec...."
    sleep 30
    caput ${camPvPrefix}:cam1:BinX.PROC 1
    caput ${camPvPrefix}:cam1:BinY.PROC 1
    caput ${camPvPrefix}:cam1:TriggerMode.PROC 1
    caput ${camPvPrefix}:cam1:ArrayCallbacks 1
    caput ${camPvPrefix}:cam1:ArrayCallbacks.PROC 1
    caput ${camPvPrefix}:cam1:Gain.PROC 1
    caput ${camPvPrefix}:cam1:AcquireTime.PROC 1
    caput ${camPvPrefix}:cam1:AcquirePeriod.PROC 1
}

reboot


exit 0

