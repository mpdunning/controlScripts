#!/usr/bin/env python
#
# scaleEnergy.py: scales magnets for new beam energy 
# currently converting from bash...
# M. Dunning 1/9/14

import sys,time,datetime
from epics import PV

args='[old onergy] [new energy] | --fromPV | --restore'

def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)

if len(sys.argv)==1 or len(sys.argv) >3:
    show_usage()
    sys.exit(1)
    
maxEnergy=130
oldEPV='ESB:ES01:OLDE'
newEPV='ESB:ES01:NEWE'
scaleFactorPV='ESB:ES01:SCALEFACTOR'
msgPV='ESB:ES01:MSG'
chicOptPV='ESB:ES01:CHIC:SCALE'  # Scale chicanes option
quadOptPV='ESB:ES01:QUAD:SCALE'  # Scale quads option
corOptPV='ESB:ES01:COR:SCALE'  # Scale xcors & ycors option

    

quads=[1350, 1375, 1400, 1490, 1570, 1640, 1720, 1790, 1860, 1940, 2020, 2050, 2070]
#quads=[2020, 2050, 2070]
chicanes=[1420, 1430, 1580, 1595, 1730, 1745]
xcors=[1350, 1375, 1400, 1490, 1510, 1570, 1640, 1720, 1790, 1860, 1940, U1, U2, U3, U4, 2030, 2110]
ycors=[1350, 1375, 1400, 1490, 1500, 1570, 1640, 1720, 1790, 1860, 1940, U1, U2, U3, U4, 2040, 2100]
    
def timestamp(format=None):
    "Formatted timestamp"
    if format == 1:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S.%f"))
    else:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S"))

def scale(list1,prefix,postfix,save=0):
    "Scales items in list1; saves old value if save=1"
    for item in list1:
        q1 = prefix + ':' + str(item) + ':' + postfix + 'DES'
        #print q1
        oldVal=PV(q1).get()
        #print oldVal
        if save==1:  # save initial value to PV
            s1=q1 + ':SAVED3'
            PV(s1).put(oldVal)
        newVal=oldVal*scaleFactor
        #print newVal
        q2 = prefix + ':' + str(item) + ':' + postfix + 'DES'
        PV(q2).put(newVal)
        
def restore(list1,prefix,postfix):
    "Restores to initial values before scaling"
    for item in list1:
        q1 = prefix + ':' + str(item) + ':' + postfix + 'DES'
        s1=q1 + ':SAVED3'
        restoreVal=PV(s1).get()
        PV(q1).put(restoreVal)

def msgDisp(msg, pause=0):
    time.sleep(pause)
    print msg
    PV(msgPV).put(msg)


if __name__ == "__main__":
    if sys.argv[1] != '--restore' and sys.argv[1] != '--fromPV':
        oldE=float(sys.argv[1])
        newE=float(sys.argv[2])
        if oldE > maxEnergy or newE > maxEnergy:
            msgDisp('Error: Energy value must be < ' + str( maxEnergy))
            msgDisp('Done',5)
            sys.exit(1)
        else:
            scaleFactor=newE/oldE
    elif sys.argv[1] == '--fromPV':
        oldE=float(PV(oldEPV).get())    
        newE=float(PV(newEPV).get())    
        if oldE > maxEnergy or newE > maxEnergy:
            msgDisp('Error: Energy value must be < ' + str( maxEnergy))
            msgDisp('Done',5)
            sys.exit(1)
        else:    
            scaleFactor=newE/oldE
            PV(scaleFactorPV).put(scaleFactor)

    if sys.argv[1] == '--restore':
        msgDisp('Restoring to initial values')
        restore(quads,'ESB:QUAD','B')
    else:
        msgDisp('Scaling by ' + str(scaleFactor))
        if PV(quadOptPV).get()==1:
            scale(quads,'ESB:QUAD','B',1)
        if PV(chicOptPV).get()==1:
            scale(chicanes,'ESB:BEND','B')
        if PV(corOptPV).get()==1:
            scale(xcors,'ESB:XCOR','B')
            scale(ycors,'ESB:YCOR','B')

msgDisp('Done',3)


exit




