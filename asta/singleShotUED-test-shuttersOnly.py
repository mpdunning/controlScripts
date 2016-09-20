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


driveShutterPvPrefix='ESB:GP01:VAL01'
drivePumpShutterPvPrefix='ESB:GP01:VAL03'
beamRate=PV(pvPrefix + ':BEAMRATE').get()

nCycles=1  # Single-shot
delayMin=0
delaySec=1  # 1 second delay from script execution to shutter open
delayMsec=0

delta=5  # Fudge factor so we don't get extra shots

if beamRate>=1:
    exposureMin=0
    exposureSec=0
    exposureMsec=(1/beamRate)*1000 - delta
elif beamRate<1:
    exposureMin=0
    exposureSec=(1/beamRate) - delta/1000
    exposureMsec=0

def singleShot(action):
    if action == 'beam':
        shutterPvPrefix=driveShutterPvPrefix
    elif action == 'beam-pump':
        shutterPvPrefix=drivePumpShutterPvPrefix
    # Close shutter
    PV(shutterPvPrefix + ':OC:CLOSE').put(1)
    sleep(0.5)
    # Set shutter parameters
    PV(shutterPvPrefix + ':FREERUN:NCYCLES').put(nCycles)
    PV(shutterPvPrefix + ':DELAY:MIN').put(delayMin)
    PV(shutterPvPrefix + ':DELAY:SEC').put(delaySec)
    PV(shutterPvPrefix + ':DELAY:MSEC').put(delayMsec)
    PV(shutterPvPrefix + ':EXPOSURE:MIN').put(exposureMin)
    PV(shutterPvPrefix + ':EXPOSURE:SEC').put(exposureSec)
    PV(shutterPvPrefix + ':EXPOSURE:MSEC').put(exposureMsec)
    PV(shutterPvPrefix + ':MODE:FAST').put(1)
    PV(shutterPvPrefix + ':TTL:OUT:HIGH').put(1)
    sleep(0.5)
    # Initiate free-run
    PV(shutterPvPrefix + ':FREERUN:START.PROC').put(1)
    
### Main program ##########################################################3

if __name__ == "__main__":
    try:
        if sys.argv[2] == 'beam':
            #singleShot('beam')
            PV(driveShutterPvPrefix).put(1)
            sleep(1/beamRate)
            PV(driveShutterPvPrefix).put(0)
        elif sys.argv[2] == 'beam-pump':
            #singleShot('beam-pump')
            PV(drivePumpShutterPvPrefix).put(1)
            sleep(1/beamRate)
            PV(drivePumpShutterPvPrefix).put(0)
        else:
            show_usage()
            sys.exit(1)
    finally:
        pass


### End ##########################################################################


exit

