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


driveShutterPvPrefix='ASTA:LSC01'
pumpShutterPvPrefix='ASTA:LSC02'
masterShutterPvPrefix='ASTA:LSC03'
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
        # Close drive shutter
        PV(shutterPvPrefix + ':OC:CLOSE').put(1)
        # Close pump shutter
        PV(pumpShutterPvPrefix + ':OC:CLOSE').put(1)
        # Open master shutter
        PV(masterShutterPvPrefix + ':OC:OPEN').put(1)
    elif action == 'beam-pump':
        shutterPvPrefix=masterShutterPvPrefix
        # Close master shutter
        PV(shutterPvPrefix + ':OC:CLOSE').put(1)
        # Open drive shutter 
        PV(driveShutterPvPrefix + ':OC:OPEN').put(1)
        # Open pump shutter
        PV(pumpShutterPvPrefix + ':OC:OPEN').put(1)
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
    shutterStatusPv=PV(shutterPvPrefix + ':STATUS:OC')
    shutterOpenPv=PV(shutterPvPrefix + ':OC:OPEN')
    sleep(0.2)
    sleep(0.2)
    print shutterStatusPv.get()
    # Initiate free-run
    PV(shutterPvPrefix + ':FREERUN:START').put(1)
    # Shutter becomes unresponsive after freerun mode, so we need a long sleep here to do anything after this point
    #sleep(2)
    #PV(shutterPvPrefix + ':OC:OPEN').put(1)
    # Or just check the status
    #while shutterStatusPv.get() != 1:
    #    shutterOpenPv.put(1)
    #    sleep(0.2)
    
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

