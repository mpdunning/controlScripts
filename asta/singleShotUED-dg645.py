#!/usr/bin/env python

# singleShotUED.py: For doing beam and pump/probe single shots for UED, using LSC shutters.

from epics import PV
from time import sleep
import sys

args='PV_PREFIX <beam|beam-pump>'
def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)
if len(sys.argv) != 3:
    show_usage()
    sys.exit(1)

pvPrefix=sys.argv[1]

# Shutters
driveShutterPvPrefix='ASTA:LSC01'
pumpShutterPvPrefix='ASTA:LSC02'
masterShutterPvPrefix='ASTA:LSC03'
# DG645
srsPvPrefix='ASTA:DG01'
srsTrigSrcPv=PV(srsPvPrefix + ':TRIG:SRC')
singleShotPv=PV(srsPvPrefix + ':TRIG:SS')
# Other

def singleShot(action):
    if action == 'beam':
        # Close master shutter
        PV(masterShutterPvPrefix + ':OC:CLOSE').put(1)
        # Open drive shutter
        PV(driveShutterPvPrefix + ':OC:OPEN').put(1)
        # Close pump shutter
        PV(pumpShutterPvPrefix + ':OC:CLOSE').put(1)
    elif action == 'beam-pump':
        # Close master shutter
        PV(masterShutterPvPrefix + ':OC:CLOSE').put(1)
        # Open pump shutter 
        PV(pumpShutterPvPrefix + ':OC:OPEN').put(1)
        # Close drive shutter
        PV(driveShutterPvPrefix + ':OC:CLOSE').put(1)
    # Make sure SRS is set to "Single-shot External Rising Edge" trigger input (RVAL=3)
    srsTrigSrcPv.put(3)
    # Make sure master shutter is set to: "Fast" mode, "TTL In High", "TTL Out High"
    PV(masterShutterPvPrefix + ':MODE:FAST').put(1) 
    PV(masterShutterPvPrefix + ':TTL:IN:HIGH').put(1) 
    PV(masterShutterPvPrefix + ':TTL:OUT:HIGH').put(1) 
    # Set SRS for single-shot
    singleShotPv.put(1)
    
### Main program ##########################################################3

if __name__ == "__main__":
    try:
        if sys.argv[2] == 'beam':
            singleShot('beam')
        elif sys.argv[2] == 'beam-pump':
            singleShot('beam-pump')
        else:
            show_usage()
            sys.exit(1)
    finally:
        pass


### End ##########################################################################


exit

