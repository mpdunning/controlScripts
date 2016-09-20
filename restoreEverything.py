#!/usr/bin/env python
#
# 
# restoreEverything.py: restores machine settings from a file
# Currently converting from bash...
# TO DO: Undo mechanism, gui file selector,...
# M. Dunning 3/29/15

import sys,os,time,datetime
from epics import PV

args='FILEPATH <DES|ACT>'
undo=0
scriptDir='/afs/slac/g/testfac/extras/scripts'
saveScript=scriptDir + '/saveEverything.sh --all'

def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)

if len(sys.argv) > 3:
    show_usage()
    sys.exit(1)

if len(sys.argv) == 2:
    if os.path.isfile(sys.argv[1]): 
        srFile=sys.argv[1]
        # Default restore type will be ACT
        restoreType='ACT'
    else:
        print sys.argv[1],'is not a valid file'
        show_usage()
        sys.exit(1)

if len(sys.argv) == 3:
    if os.path.isfile(sys.argv[1]): 
        srFile=sys.argv[1]
        restoreType=sys.argv[2]
    else:
        print sys.argv[1],'is not a valid file'
        show_usage()
        sys.exit(1)


def restoreFromFile(file,type):
    "Restores PVs from a file"
    # First, save current setup
    os.system(saveScript)
    print 'PV_NAME OLD_VAL NEW_VAL'
    print 'Restoring from ', type
    with open(file) as f:
        for line in f:
            if type in line:
            #if line.startswith('ESB:QUAD:20') and type in line:
                pv=line.split()[0]
                if 'ACT' in pv:
                    pv=pv.replace('ACT','DES')
                newVal=line.split()[1]
                oldVal=PV(pv).get()
                print pv,oldVal,newVal
                # Set new value
                PV(pv).put(newVal)

def undoRestore(file,type):
    "Undoes a restore"


if __name__ == "__main__":
    restoreFromFile(srFile,restoreType)



# To be continued

exit
