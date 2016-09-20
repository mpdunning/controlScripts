#!/usr/bin/env python
# mdunning 9/15/16

import subprocess
import sys
from time import sleep
from epics import PV

args='PV_PREFIX INPUT_NUMBER'
def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)
if len(sys.argv) != 3:
    show_usage()
    sys.exit(1)

pv_prefix = sys.argv[1]
input_num = sys.argv[2]
        
priority_pv = PV('GUN:AS01:1:GN1:RWAV.PRIO')
script = '/afs/slac/g/testfac/extras/scripts/pvLog/pvLog-dataDump.py'
##################################################################################################################

priority_pv.put(2)
sleep(0.5)
subprocess.call([script, pv_prefix, input_num, 'dump'])
sleep(0.5)
priority_pv.put(0)
sleep(0.5)
if priority_pv.get() != 0:
    priority_pv.put(0)

sys.exit(0)

