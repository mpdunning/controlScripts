#!/usr/bin/env python
#
# saveEverything.py: saves machine settings 
# currently converting from bash...
# M. Dunning 11/13/14

import sys,time,datetime
from epics import PV

#args='[--all | --quads | --chicanes | --xcors | --ycors | --bends | --btrms | --qtrms | --motors | --ampls]'
args='[--all]'

def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)

if len(sys.argv) >2:
    show_usage()
    sys.exit(1)

#if len(sys.argv)==1 or sys.argv[1]== '--all'

def timestamp(format=None):
    "Formatted timestamp"
    if format == 1:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S.%f"))
    elif format == 2:
        return(datetime.datetime.now().strftime("%Y"))
    else:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S"))

srDir='/nfs/slac/g/nlcta/u01/nlcta/saveRestore/test/' + timestamp(2) + '/'

#quadList=[2020, 2050, 2070]
quadList=[480, 530, 560, 575, 590, 1030, 1070, 1110, 1130, 1250, 1350, 1375, 1400, 1490, 1570, 1640, 1720, 1790, 1860, 1940, 2020, 2050, 2070]
xcorList=[312, 342, 452, 480, 530, 560, 575, 590, 610, 690, 910, 990, 1030, 1070, 1110, 1130, 1250, 1350, 1375, 1400, 1490, 1510, 1570, 1640, 1720, 1790, 1860, 'U1', 'U2', 'U3', 'U4', 1940, 2030, 2110]
ycorList=[312, 342, 452, 480, 530, 560, 575, 590, 1030, 1070, 1110, 1130, 1250, 1350, 1375, 1400, 1490, 1500, 1570, 1640, 1720, 1790, 1860, 'U1', 'U2', 'U3', 'U4', 1940, 2040, 2100]
bendList=[320, 610, 1420, 1430, 1580, 1595, 1730, 1745, 2110]
chicList=[0, 1, 2]
btrmList=[1430, 1445, 1455, 1595, 1610, 1625, 1745, 1760, 1775]
qtrmList=[1590, 1620, 1740, 1770]
solList=[305]
stnList=[3]
motrList=['XPS1:m3', 'XPS1:m4', 'XPS1:m5', 'XPS1:m6', 'XPS1:m7', 'XPS2:m2', 'XPS3:m1', 'XPS3:m2', 'XPS3:m3', 'XPS3:m4', 'XPS3:m5', 'XPS3:m6', 'XPS3:m7', 'XPS4:m1', 'XPS4:m2', 'XPS4:m3']
amplList=[38, 122, 125, 126]


def saveGroup(type, list, var, prefix='ESB'):
    "Saves each item in a list"
    datafile.write('###  ' + type + 's  ###') 
    datafile.write('\n')
    for item in list:
        if type=='PHS' or type=='AMP':
            desPVName= prefix + ':STN' + str(item) + ':' + type + ':' + 'DES'
            actPVName= prefix + ':STN' + str(item) + ':' + type + ':' + 'ACT'
            desPVVal= PV(desPVName).get()
            actPVVal= PV(actPVName).get()
        elif type=='MOTR':
            desPVName= prefix + ':' + str(item) + ':'  + type
            actPVName= prefix + ':' + str(item) + ':'  + type + '.RBV'
            desPVVal= PV(desPVName).get()
            actPVVal= PV(actPVName).get()
        else:
            desPVName= prefix + ':' + type + ':' + str(item) + ':' + var + 'DES'
            actPVName= prefix + ':' + type + ':' + str(item) + ':' + var + 'ACT'
            desPVVal= PV(desPVName).get()
            actPVVal= PV(actPVName).get()
        datafile.write(desPVName + ' ' + str(desPVVal) + '\n')
        datafile.write(actPVName + ' ' + str(actPVVal) + '\n')
    datafile.write('\n')
        

if __name__ == "__main__":
    with open(srDir + 'test-' + str(timestamp()) + '.sr', 'w') as datafile:
        datafile.write('####  Everything: ' + str(timestamp()) + '  ####' + '\n')
        datafile.write('==================================================' + '\n\n')
        datafile.write('PV_NAME' + ' ' + 'PV_VAL' + '\n')
        datafile.write('--------------------------------------------------' + '\n')
        saveGroup('QUAD', quadList, 'B')
        saveGroup('XCOR', xcorList, 'B')
        saveGroup('YCOR', ycorList, 'B')
        saveGroup('BEND', bendList, 'B')
        saveGroup('CHIC', chicList, 'R56:')
        saveGroup('BTRM', btrmList, 'B')
        saveGroup('QTRM', qtrmList, 'B')
        saveGroup('SOL',  solList,  'B')
        saveGroup('MOTR', motrList, '')
        saveGroup('PHS',  stnList,  '')
        saveGroup('AMP',  stnList,  '')
        saveGroup('AMPL', amplList, 'V', 'TA02')
        datafile.write('\n')

exit
