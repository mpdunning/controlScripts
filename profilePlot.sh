#!/bin/bash
#
# profilePlot.sh: plots profiles using areaDetector Stats plugin
# M. Dunning 4/27/13

args="[CAM PVPREFIX]"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 1 ]; then
    show_usage
    exit 1
fi

pvPrefix=$1
target=profilePlot
arch=`uname -i`

if [ "$arch" = "i386" ]; then
    qArch=arch-32
else
    qArch=arch-64
fi

caput $pvPrefix:Stats1:EnableCallbacks 1
caput $pvPrefix:Stats1:ComputeStatistics 1
caput $pvPrefix:Stats1:ComputeCentroid 1
caput $pvPrefix:Stats1:ComputeProfiles 1


#/afs/slac/g/testfac/workspace/mdunning/qt/$target/$qArch/$target -m P=$1
edm -x -eolc -m P=${1}:,R=Stats1:,TITLE1="Projection X",TITLE2="Projection Y",TITLE3="Centroid X",TITLE4="Centroid Y",DATA1=ProfileAverageX_RBV,DATA2=ProfileAverageY_RBV,DATA3=ProfileCentroidX_RBV,DATA4=ProfileCentroidY_RBV,XLABEL=Pixel,YLABEL=Counts,N=ArraySize0_RBV gcNDPlotAll.edl

exit 0

