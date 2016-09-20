#!/bin/bash
#
# startQCam.sh: starts qt image viewer
# M. Dunning 4/27/13

args="VIEWER CAMERA NUMBER"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 2 ]; then
    show_usage
    exit 1
fi

arch=`uname -i`
if [ "$arch" = "x86_64" ]; then
    qArch=arch-64
else
    qArch=arch-32
fi

viewer=$1
cam=$2
dispDir=/afs/slac/g/testfac/tools/display
qCamDir=$dispDir/qCam/prod/qCam8bit/$qArch
areaD=$dispDir/areaD/edl

if [ "$ACCELERATOR" = "nlcta" ]; then
    prefix=13PS${cam}
    a=`caget -t $prefix:cam1:PDU`
    n=`caget -t $prefix:cam1:OUTLET`
    ioc=sioc-esb-adps${cam}
    pduPV=ESB:ACSW$a:BO:REBOOT:${n}
    pduRBVPV=ESB:ACSW$a:BO:SC:STATE:${n}
elif [ "$ACCELERATOR" = "asta" ]; then
    prefix=ASPS${cam}
    a=`caget -t $prefix:cam1:PDU`
    n=`caget -t $prefix:cam1:OUTLET`
    ioc=sioc-asta-adps${cam}
    pduPV=ACSW:AS01:NW0${a}:${n}HARDRESET
    pduRBVPV=ACSW:AS01:NW0${a}:${n}POWERSTATE
elif [ "$ACCELERATOR" = "esa" ]; then
    prefix=PS${cam}
    a=`caget -t $prefix:cam1:PDU`
    n=`caget -t $prefix:cam1:OUTLET`
    ioc=sioc-esa-adps${cam}
    pduPV=ESA:ACSW$a:BO:REBOOT:${n}
    pduRBVPV=ESA:ACSW$a:BO:SC:STATE:${n}
else
    prefix=13PS${cam}
    a=`caget -t $prefix:cam1:PDU`
    n=`caget -t $prefix:cam1:OUTLET`
    ioc=sioc-esb-adps${cam}
    pduPV=ESB:ACSW$a:BO:REBOOT:${n}
    pduRBVPV=ESB:ACSW$a:BO:SC:STATE:${n}
fi

#echo "$ACCELERATOR $qArch $cam $prefix $ioc $pduPV $pduRBVPV $dispDir"

if [ -z "$a" -o -z "$n" ]; then
    if [ "$viewer" = "qCam" ]; then
        $qCamDir/qCam -m P=$prefix,IOC=$ioc,CAMSERVER=$CAMSERVER
    elif [ "$viewer" = "AD" ]; then
        edm -x -eolc -m P=$prefix:,R=cam1:,IOC=$ioc,CAMSERVER=$CAMSERVER $areaD/gcADBase.edl &
    elif [ "$viewer" = "edm" ]; then
        edm -x -eolc -m P=$prefix:,R=cam1:,IOC=$ioc,CAMSERVER=$CAMSERVER $areaD/edmViewer.edl
    else
        echo "Invalid viewer $viewer"
    fi
else
    if [ "$viewer" = "qCam" ]; then
        $qCamDir/qCam -m P=$prefix,P2=$pduPV,P3=$pduRBVPV,IOC=$ioc,CAMSERVER=$CAMSERVER
    elif [ "$viewer" = "AD" ]; then
        edm -x -eolc -m P=$prefix:,R=cam1:,P2=$pduPV,P3=$pduRBVPV,IOC=$ioc,CAMSERVER=$CAMSERVER $areaD/gcADBase.edl &
    elif [ "$viewer" = "edm" ]; then
        edm -x -eolc -m P=$prefix:,R=cam1:,P2=$pduPV,P3=$pduRBVPV,IOC=$ioc,CAMSERVER=$CAMSERVER $areaD/edmViewer.edl
    else
        echo "Invalid viewer $viewer"
    fi
fi


exit 0

