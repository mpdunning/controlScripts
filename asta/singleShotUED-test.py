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
driveShutterPvPrefix='ESB:GP01:VAL01'
pumpShutterPvPrefix='ESB:GP01:VAL02'
masterShutterPvPrefix='ESB:GP01:VAL03'
# DG645
srsPvPrefix='ASTA:DG01'
srsTrigSrcPv=PV(srsPvPrefix + ':TRIG:SRC')
singleShotPv=PV(srsPvPrefix + ':TRIG:SS')
# Other
beamRate=PV(pvPrefix + ':BEAMRATE').get()

def singleShot(action):
    PV(driveShutterPvPrefix + ':MODE:FAST').put(1)         
    PV(pumpShutterPvPrefix + ':MODE:FAST').put(1)         
    PV(driveShutterPvPrefix + ':TTL:IN:DISABLE').put(1)
    PV(pumpShutterPvPrefix + ':TTL:IN:DISABLE').put(1)
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
        # Open drive shutter
        PV(driveShutterPvPrefix + ':OC:OPEN').put(1)
    # Make sure SRS is set to "Single-shot External Rising Edge" trigger input (RVAL=3)
    srsTrigSrcPv.put(3)
    # Make sure master shutter is set to: "Fast" mode, "TTL In High", "TTL Out High"
    PV(masterShutterPvPrefix + ':MODE:FAST').put(1) 
    PV(masterShutterPvPrefix + ':TTL:IN:HIGH').put(1)
    PV(masterShutterPvPrefix + ':TTL:OUT:HIGH').put(1) 
    # Set SRS for single-shot
    singleShotPv.put(1)
    sleep(0.5) 
    PV(masterShutterPvPrefix + ':TTL:IN:DISABLE').put(1)

def singleShotTest(action):
    if action == 'beam':
        # Close master shutter
        PV(masterShutterPvPrefix).put(0)
        # Open drive shutter
        PV(driveShutterPvPrefix).put(1)
        # Close pump shutter
        PV(pumpShutterPvPrefix).put(0)
    elif action == 'beam-pump':
        # Close master shutter
        PV(masterShutterPvPrefix).put(0)
        # Open pump shutter 
        PV(pumpShutterPvPrefix).put(1)
        # Open drive shutter
        PV(driveShutterPvPrefix).put(1)
    PV(masterShutterPvPrefix).put(1)
    sleep(1/beamRate)
    PV(masterShutterPvPrefix).put(0)
    
    
### Main program ##########################################################3

if __name__ == "__main__":
    try:
        if sys.argv[2] == 'beam':
            singleShotTest('beam')
        elif sys.argv[2] == 'beam-pump':
            singleShotTest('beam-pump')
        else:
            show_usage()
            sys.exit(1)
    finally:
        pass


### End ##########################################################################


exit

