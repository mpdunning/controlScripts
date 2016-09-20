#!/bin/bash
# prof_int.sh
# Does some checking to make sure it's  safe to inser/retract profs or filters, stoppers, etc. and then inserts/retracts the item
# Usage: ./profint.sh <prof>  #where <prof> is a profile monitor, filter, or stopper
# 
# Logic:
# 1) should be able to ALWAYS remove ALL profs if they are in
# 2) should be able to ALWAYS insert a filter OR stopper if they are out
# 3) should be able to insert profs 1520, 1545, OR 1550 if EITHER the laser1 stopper or filter is in
# 4) should be able to remove EITHER the laser1 stopper OR filter if profs 1520, 1545, OR 1550 are in
# 5) should be able to insert profs 1665, 1700, OR 1705 if EITHER the laser2 stopper or filter is in
# 6) should be able to remove EITHER the laser2 stopper OR filter if profs 1665, 1700, OR 1705 are in
#

filterLaser1=ESB:BO:2124-14:BIT3
stopperLaser1=ESB:BO:2124-14:BIT1
filterLaser2=ESB:BO:2124-14:BIT2
stopperLaser2=ESB:BO:2124-14:BIT4
prof1520=ESB:BO:2114-1:BIT1
prof1545=ESB:BO:2114-14:BIT1
prof1550=ESB:BO:2114-1:BIT4
prof1665=ESB:BO:2114-1:BIT7
prof1700=ESB:BO:2114-11:BIT7
prof1705=ESB:BO:2114-1:BIT8

msg1="Remove profs or insert laser stopper first"
msg2="Insert laser stopper or filters first"
edmDir=/afs/slac/g/testfac/tools/display/nlcta/edl

########## functions ####################
#########################################

insertLaser1Prof () {
	filter=$filterLaser1
	stopper=$stopperLaser1
	if [[( "`caget -tn $filter`" -eq "1" )&&( "`caget -tn $prof`" -eq "0" )]]; then
		caput -n $filter 1
		caput -n $prof 1
	elif [[( "`caget -tn $stopper`" -eq "1" )&&( "`caget -tn $prof`" -eq "0" )]]; then
		caput -n $stopper 1
		caput -n $prof 1
	elif [ "`caget -tn $prof`" -eq "1" ]; then
		caput -n $prof 0
	else 
		echo $msg2	
		edm -x -eolc -m MSG1=Caution! -m MSG2="$msg2" $edmDir/message.edl
	fi	
} 

insertLaser2Prof () {
	filter=$filterLaser2
	stopper=$stopperLaser2
	if [[( "`caget -tn $filter`" -eq "1" )&&( "`caget -tn $prof`" -eq "0" )]]; then
		caput -n $filter 1
		caput -n $prof 1
	elif [[( "`caget -tn $stopper`" -eq "1" )&&( "`caget -tn $prof`" -eq "0" )]]; then
		caput -n $stopper 1
		caput -n $prof 1
	elif [ "`caget -tn $prof`" -eq "1" ]; then
		caput -n $prof 0
	else 
		echo $msg2	
		edm -x -eolc -m MSG1=Caution! -m MSG2="$msg2" $edmDir/message.edl
	fi	
} 

insertLaser1Other () {
	p1=$prof1520
	p2=$prof1545
	p3=$prof1550
	if [[( "`caget -tn $p1`" -eq "0" && "`caget -tn $p2`" -eq "0" && "`caget -tn $p3`" -eq "0" )&&( "`caget -tn $x1`" -eq "1" )]]; then
		caput -n $x1 0
	elif [ "`caget -tn $x1`" -eq "0" ]; then
		caput -n $x1 1
	elif [[( "`caget -tn $p1`" -eq "1" || "`caget -tn $p2`" -eq "1" || "`caget -tn $p3`" -eq "1" )&&( "`caget -tn $x1`" -eq "1" && "`caget -tn $x2`" -eq "1" )]]; then
		caput -n $x2 1
		caput -n $x1 0
	else 
		echo $msg1
		edm -x -eolc -m MSG1=Caution! -m MSG2="$msg1" $edmDir/message.edl
	fi
}

insertLaser2Other () {
	p1=$prof1665
	p2=$prof1700
	p3=$prof1705
	if [[( "`caget -tn $p1`" -eq "0" && "`caget -tn $p2`" -eq "0" && "`caget -tn $p3`" -eq "0" )&&( "`caget -tn $x1`" -eq "1" )]]; then
		caput -n $x1 0
	elif [ "`caget -tn $x1`" -eq "0" ]; then
		caput -n $x1 1
	elif [[( "`caget -tn $p1`" -eq "1" || "`caget -tn $p2`" -eq "1" || "`caget -tn $p3`" -eq "1" )&&( "`caget -tn $x1`" -eq "1" && "`caget -tn $x2`" -eq "1" )]]; then
		caput -n $x2 1
		caput -n $x1 0
	else 
		echo $msg1
		edm -x -eolc -m MSG1=Caution! -m MSG2="$msg1" $edmDir/message.edl
	fi
}

##########################################
##########################################

if [ "$1" = "" ]; then
 	echo "Error - Usage: ./prof_int.sh <prof>"
else
	############ profile monitor insertion #####################
	#############################################################
	if [ "$1" = "PROF1520" ]; then
		prof=$prof1520
		insertLaser1Prof
	elif [ "$1" = "PROF1545" ]; then
		prof=$prof1545
		insertLaser1Prof
	elif [ "$1" = "PROF1550" ]; then
		prof=$prof1550
		insertLaser1Prof
	elif [ "$1" = "PROF1665" ]; then
		prof=$prof1665
		insertLaser2Prof
	elif [ "$1" = "PROF1700" ]; then
		prof=$prof1700
		insertLaser2Prof
	elif [ "$1" = "PROF1705" ]; then
		prof=$prof1705
		insertLaser2Prof
	############ filter & stopper insertion #####################
	#############################################################
	elif [ "$1" = "laser1_Filter" ]; then
		x1=$filterLaser1
		x2=$stopperLaser1
		insertLaser1Other
	elif [ "$1" = "laser1_Stopper" ]; then
		x1=$stopperLaser1
		x2=$filterLaser1
		insertLaser1Other
	elif [ "$1" = "laser2_Filter" ]; then
		x1=$filterLaser2
		x2=$stopperLaser2
		insertLaser2Other
	elif [ "$1" = "laser2_Stopper" ]; then
		x1=$stopperLaser2
		x2=$filterLaser2
		insertLaser2Other
	fi
fi



exit 0

