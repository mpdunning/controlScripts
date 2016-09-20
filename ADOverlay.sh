#!/bin/bash
#
# ADOverlay.sh: enables/disables overlays for qCam/areaDetector
# M. Dunning 12/16/13

args="CAM_PVPREFIX OVERLAY <--enable | --disable>"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 3 ]; then
    show_usage
    exit 1
fi

pvPrefix=$1
overlay=$2

if [ "`echo "${pvPrefix}" | grep PS`" ]; then
    NDAP0=PSx
elif [ "`echo "${pvPrefix}" | grep ANDOR`" ]; then
    NDAP0=ANDOR
else
    NDAP0=PSx
fi

if [ "$overlay" = "TARGET" ]; then
    overlayNumber=2
    shape=Cross
    sizex=60
    sizey=60
    green=255
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionXLink.DOL ${pvPrefix}:cam1:${overlay}X CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionYLink.DOL ${pvPrefix}:cam1:${overlay}Y CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeX $sizex
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeY $sizey
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeXLink.DOL 0  
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeYLink.DOL 0
elif [ "$overlay" = "BEAM" ]; then
    overlayNumber=3
    shape=Cross
    sizex=40
    sizey=40
    green=200
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionXLink.DOL ${pvPrefix}:cam1:${overlay}X CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionYLink.DOL ${pvPrefix}:cam1:${overlay}Y CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeX $sizex
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeY $sizey
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeXLink.DOL 0  
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeYLink.DOL 0
elif [ "$overlay" = "CENTROID" ]; then
    overlayNumber=4
    shape=Cross
    sizex=80
    sizey=80
    green=150
    caput ${pvPrefix}:Stats1:EnableCallbacks 1
    caput ${pvPrefix}:Stats1:ComputeCentroid 1
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionXLink.DOL ${pvPrefix}:Stats1:CentroidX_RBV CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionYLink.DOL ${pvPrefix}:Stats1:CentroidY_RBV CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeX $sizex
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeY $sizey
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeXLink.DOL 0  
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeYLink.DOL 0
elif [ "$overlay" = "ROI1" ]; then
    roi=1
    overlayNumber=5
    shape=Rectangle
    green=125
    caput ${pvPrefix}:ROI${roi}:NDArrayPort $NDAP0
    caput ${pvPrefix}:ROI${roi}:EnableCallbacks 1
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionXLink.DOL ${pvPrefix}:ROI${roi}:MinX CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionYLink.DOL ${pvPrefix}:ROI${roi}:MinY CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeXLink.DOL ${pvPrefix}:ROI${roi}:SizeX CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeYLink.DOL ${pvPrefix}:ROI${roi}:SizeY CPP
    caput ${pvPrefix}:ROI${roi}:EnableZ 0
elif [ "$overlay" = "ROI2" ]; then
    roi=2
    overlayNumber=6
    shape=Rectangle
    green=125
    caput ${pvPrefix}:ROI${roi}:NDArrayPort $NDAP0
    caput ${pvPrefix}:ROI${roi}:EnableCallbacks 1
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionXLink.DOL ${pvPrefix}:ROI${roi}:MinX CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionYLink.DOL ${pvPrefix}:ROI${roi}:MinY CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeXLink.DOL ${pvPrefix}:ROI${roi}:SizeX CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeYLink.DOL ${pvPrefix}:ROI${roi}:SizeY CPP
    caput ${pvPrefix}:ROI${roi}:EnableZ 0
elif [ "$overlay" = "ROI3" ]; then
    roi=3
    overlayNumber=7
    shape=Rectangle
    green=125
    caput ${pvPrefix}:ROI${roi}:NDArrayPort $NDAP0
    caput ${pvPrefix}:ROI${roi}:EnableCallbacks 1
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionXLink.DOL ${pvPrefix}:ROI${roi}:MinX CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:PositionYLink.DOL ${pvPrefix}:ROI${roi}:MinY CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeXLink.DOL ${pvPrefix}:ROI${roi}:SizeX CPP
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeYLink.DOL ${pvPrefix}:ROI${roi}:SizeY CPP
    caput ${pvPrefix}:ROI${roi}:EnableZ 0
else
    show_usage
    exit 1
fi
    

if [ "$3" = "--enable" ]; then
    caput ${pvPrefix}:Over1:NDArrayPort $NDAP0
    caput ${pvPrefix}:Over1:EnableCallbacks 1   
    caput ${pvPrefix}:Over1:${overlayNumber}:Use 1
    caput ${pvPrefix}:Over1:${overlayNumber}:Green $green
    caput ${pvPrefix}:Over1:${overlayNumber}:Shape $shape
    caput ${pvPrefix}:Over1:${overlayNumber}:Name $overlay
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeX $sizex
    caput ${pvPrefix}:Over1:${overlayNumber}:SizeY $sizey
    caput ${pvPrefix}:Over1:${overlayNumber}:WidthX 2
    caput ${pvPrefix}:Over1:${overlayNumber}:WidthY 2
    caput ${pvPrefix}:image1:NDArrayPort OVER1
elif [ "$3" = "--disable" ]; then
    caput ${pvPrefix}:Over1:${overlayNumber}:Use 0
    #caput ${pvPrefix}:Over1:EnableCallbacks 0   
    #caput ${pvPrefix}:image1:NDArrayPort $NDAP0
elif [ "$3" = "--setROI" ]; then
    caput ${pvPrefix}:image1:NDArrayPort ROI${roi}
    caput ${pvPrefix}:ROI${roi}:NDArrayPort $NDAP0
    caput ${pvPrefix}:Stats1:NDArrayPort OVER1
elif [ "$3" = "--unsetROI" ]; then
    caput ${pvPrefix}:image1:NDArrayPort $NDAP0
    caput ${pvPrefix}:ROI${roi}:NDArrayPort $NDAP0
    caput ${pvPrefix}:Stats1:NDArrayPort $NDAP0
    caput ${pvPrefix}:cam1:SizeX `caget -t ${pvPrefix}:cam1:MaxSizeX_RBV`
    caput ${pvPrefix}:cam1:SizeY `caget -t ${pvPrefix}:cam1:MaxSizeY_RBV`
    caput ${pvPrefix}:cam1:MinX 0
    caput ${pvPrefix}:cam1:MinY 0
else
    show_usage
fi


exit 0

