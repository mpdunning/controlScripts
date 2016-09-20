#!/bin/bash
#
# Saves and subtracts a background image, for use with AreaDetector
# M. Dunning 11/17/15

args="<set | unset> CAM_PVPREFIX"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 2 ]; then
    show_usage
    exit 1
fi

pvPrefix=$2
if [ "`echo -n $pvPrefix | tail -c 1`" = ":" ]; then
    pvPrefix=`echo "$pvPrefix" | sed s'/:$//'`
fi

if [ "`echo "$pvPrefix" | grep PS`" ]; then
    NDAP0=PSx
elif [ "`echo "$pvPrefix" | grep ANDOR`" ]; then
    NDAP0=ANDOR
else
    NDAP0=PSx
fi

#echo "$pvPrefix"

if [ "$1" == "set" ]; then
    caput ${pvPrefix}:Proc1:EnableCallbacks 1    
    caput ${pvPrefix}:Proc1:EnableBackground 1
    caput ${pvPrefix}:Proc1:SaveBackground 1
    caput ${pvPrefix}:Proc1:LowClip 0
    caput ${pvPrefix}:Proc1:EnableLowClip 1
    caput ${pvPrefix}:image1:NDArrayPort PROC1
    caput ${pvPrefix}:Stats1:NDArrayPort PROC1
elif [ "$1" == "unset" ]; then
    caput ${pvPrefix}:Proc1:EnableCallbacks 0
    caput ${pvPrefix}:Proc1:EnableBackground 0
    caput ${pvPrefix}:Proc1:EnableLowClip 0
    caput ${pvPrefix}:image1:NDArrayPort $NDAP0
    caput ${pvPrefix}:Stats1:NDArrayPort $NDAP0
else
    echo "Invalid option $1"
fi


exit 0

