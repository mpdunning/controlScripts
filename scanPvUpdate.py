#!/usr/bin/env python

from epics import PV
import sys

args='PV_PREFIX SCANPV_NUMBER'

def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)

if len(sys.argv) != 3:
    show_usage()
    sys.exit(1)

pvPrefix=sys.argv[1]
scanPvNumber=sys.argv[2]

valPv=PV(pvPrefix + ':SCANPV' + scanPvNumber + ':VAL.INP')
rbvPv=PV(pvPrefix + ':SCANPV' + scanPvNumber + ':RBV.INP')
namePv=PV(pvPrefix + ':SCANPV' + scanPvNumber + ':PVNAME')
typePv=PV(pvPrefix + ':SCANPV' + scanPvNumber + ':PVTYPE')

pvName=namePv.get(as_string=True)
pvType=typePv.get()


if pvType == 1:
    if pvName.endswith('.RBV'):
        rbv=pvName
        #pvName=pvName.rstrip('.RBV')
        pvName=pvName.replace('.RBV', '')
    else:
        rbv=pvName + '.RBV'
elif pvType == 2:
    if pvName.endswith('ACTPOS'):
        rbv=pvName
        pvName=':'.join(pvName.split(':')[0:2]) + ':AO:ABSMOV'
    else:
        rbv=':'.join(pvName.split(':')[0:2]) + ':AI:ACTPOS'
elif pvType == 3:
    if 'ESB' in pvName:
        rbv = pvName.split(':')[0] + ':CALC:' + ':'.join(pvName.split(':')[3:5]) + ':POS:MM'
    elif 'UEDM' in pvName:
        rbv = pvName.split(':')[0] + ':UEDM:' + 'AI:' + pvName.split(':')[-2] + ':POS'
    else:
        rbv = pvName.split(':')[0] + ':CALC:' + ':'.join(pvName.split(':')[2:3]) + ':POS:MM'
elif pvType == 4:
    if pvName.endswith('ACT'):
        rbv=pvName
        pvName=pvName.rstrip('ACT') + 'DES'
    else:
        rbv=pvName.rstrip('DES') + 'ACT'
elif pvType == 5:
    if pvName.endswith('RBV'):
        pvName=pvName.replace('_RBV','')
        rbv=pvName.replace('OUT','IN')
        rbv=rbv.replace(':SP','')
    elif 'IN' in pvName:
        rbv=pvName
        pvName=pvName.replace('IN','OUT')
        pvName+=':SP'
    else:
        rbv=pvName.replace('OUT','IN')
        rbv=rbv.replace(':SP','')
else:
    rbv=pvName

#print 'PV name: ', pvName
#print 'RBV: ', rbv

valPv.put(pvName + ' CPP')
rbvPv.put(rbv + ' CPP')


exit
