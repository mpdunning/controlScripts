#!/bin/bash
#
# grab.sh: grabs n images and saves them to disk
# M. Dunning 3/18/13

args="CAM_PVPREFIX NUMBER_OF_IMAGES [--view] [--timestamp]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -gt 3 ]; then
    show_usage
    exit 1
fi

# set up filename format
today=`date +%Y%m%d`
now=`date +%Y%m%d_%H%M%S`
pvPrefix=$1
if [ "`echo -n $pvPrefix | tail -c 1`" = ":" ]; then
    pvPrefix=`echo "$pvPrefix" | sed s'/:$//'`
fi

#echo "$pvPrefix"

# set number of images to grab
if [ "$numIm" == "fromPv" ]; then
    numIm=`caget -t $pvPrefix:TIFF1:NumCapture`
else
    numIm=$2
fi

# set directory to save to
imageDir=$NFSHOME/profileMonitor/grabImages/$today/$pvPrefix

if [ ! -d "$imageDir" ]; then
    mkdir -p $imageDir
fi

# set up PVs & capture
caput -t    $pvPrefix:TIFF1:EnableCallbacks 1 
caput -t -S $pvPrefix:TIFF1:FilePath $imageDir 
caput -t -S $pvPrefix:TIFF1:FileName $pvPrefix
caput -t    $pvPrefix:TIFF1:AutoIncrement 1
caput -t    $pvPrefix:TIFF1:FileWriteMode 1
caput -t    $pvPrefix:TIFF1:AutoSave 1
if [ "$3" = "--timestamp" -o "$4" = "--timestamp" ]; then
    caput -t $pvPrefix:TIFF1:NumCapture 1
    for (( i=1; i<=$numIm; i++ )); do
        filetemp=%s%s_`date +%Y%m%d_%H%M%S.%6N`_%3.3d.tif
        caput -t -S $pvPrefix:TIFF1:FileTemplate $filetemp
        caput -t -c $pvPrefix:TIFF1:Capture 1
    done
else
    filetemp=%s%s_`date +%Y%m%d_%H%M%S`_%3.3d.tif
    caput -t    $pvPrefix:TIFF1:NumCapture $numIm
    caput -t -S $pvPrefix:TIFF1:FileTemplate $filetemp
    caput -t    $pvPrefix:TIFF1:Capture 1
fi

if [ "$3" = "--view" ]; then
    sleep 0.5
    eog `caget -t -S $pvPrefix:TIFF1:FullFileName_RBV` &
fi

exit 0

