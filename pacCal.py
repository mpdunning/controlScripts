#!/usr/bin/env python

from epics import PV
from time import sleep
import matplotlib.pyplot as plt
import sys

#ctrlPvPrefix='ESB:STN1'
#pacPvPrefix='ESB:XBSTN1:180:L1X'
#padPvPrefix='ESB:XBSTN1:K1:011'
ctrlPvPrefix=sys.argv[1]
pacPvPrefix=sys.argv[2]
padPvPrefix=sys.argv[3]

msgPv=PV(ctrlPvPrefix + ':CAL:MSG')
msgPv.put('Calibrating...')

qOffPv=PV(pacPvPrefix + '_Q_OFFSET')
qOffMinPv=PV(pacPvPrefix + '_Q_OFFSET.LOPR')
qOffMaxPv=PV(pacPvPrefix + '_Q_OFFSET.HOPR')
iOffPv=PV(pacPvPrefix + '_I_OFFSET')
iOffMinPv=PV(pacPvPrefix + '_I_OFFSET.LOPR')
iOffMaxPv=PV(pacPvPrefix + '_I_OFFSET.HOPR')
stdPv=PV(ctrlPvPrefix + ':STD:CH0')
pulseModePv=PV(ctrlPvPrefix + ':PULSEMODE')  # 0=Kly, 1=SLED, 2=Cal

# Get initial pulse mode
pulseMode0Str=pulseModePv.get(as_string=True)
pulseMode0=pulseModePv.get(as_string=False)
print '\nStarting calibration'
print 'Initial pulse mode: %s' %(pulseMode0Str)
# Set pulse mode to Calibrate (flat pulse)
pulseModePv.put(2)
# Get initial values
qOff0=qOffPv.get()
iOff0=iOffPv.get()
std0=stdPv.get()

iterCount=0

def calRoutine(nSteps=10, minQ=-8191, maxQ=8191, minI=-8191, maxI=8191, printFlag=0, plotFlag=0):
    global iterCount
    iterCount+=1
    # Change offset limits 
    qOffMinPv.put(minQ)
    qOffMaxPv.put(maxQ)
    iOffMinPv.put(minI)
    iOffMaxPv.put(maxI)
    sleep(0.25)
    qOffMin=qOffMinPv.get()
    qOffMax=qOffMaxPv.get()
    iOffMin=iOffMinPv.get()
    iOffMax=iOffMaxPv.get()
    paramList=[[],[],[]]
    global qInc
    global iInc
    qInc=(qOffMax-qOffMin)/(nSteps-1)
    iInc=(iOffMax-iOffMin)/(nSteps-1)
    print 'Starting pass %s: nSteps=%s, qInc=%s, iInc=%s' %(iterCount, nSteps, qInc, iInc)
    for i in range(nSteps):
        newPosQ=qOffMin + i*qInc
        qOffPv.put(newPosQ)
        for j in range(nSteps):
            newPosI=iOffMin + j*iInc
            iOffPv.put(newPosI)
            #sleep(1.25)
            sleep(0.125)
            paramList[0].append(qOffPv.get())
            paramList[1].append(iOffPv.get())
            paramList[2].append(stdPv.get())
    #print paramList
    if printFlag:
        print '%-6s %-6s %-6s %-6s' %('index', 'qOff', 'iOff', 'std')
        for i in range(nSteps*nSteps):
            sys.stdout.write('%-6s' %(i))
            for j in range(3):
                sys.stdout.write('%-6s ' %(paramList[j][i]))
            sys.stdout.write('\n')
    minStd=min(paramList[2])
    indexStd=paramList[2].index(minStd)
    global qOffDes
    global iOffDes
    qOffDes=paramList[0][indexStd]
    iOffDes=paramList[1][indexStd]
    print 'Finished pass %s: min=%s, index=%s, qOff=%s, iOff=%s' %(iterCount, minStd, indexStd, qOffDes, iOffDes)
    # Set i,q to where std is min
    qOffPv.put(qOffDes)
    iOffPv.put(iOffDes)
    if plotFlag:
        # Plot results
        plt.subplot(2, 1, 1)
        plt.plot(paramList[0], paramList[2], 'ko')
        plt.xlabel('Q offset')
        plt.ylabel('Stdev')
        plt.title('Calibration curves')
        plt.subplot(2, 1, 2)
        plt.plot(paramList[1], paramList[2], 'r.')
        plt.xlabel('I offset')
        plt.ylabel('Stdev')
        plt.show()
     
if __name__ == '__main__':
    args='CTRL_PV_PREFIX PAC_PV_PREFIX PAD_PV_PREFIX'
    def show_usage():
        "Prints usage"
        print 'Usage: %s %s' %(sys.argv[0], args)
    if len(sys.argv) != 4:
        show_usage()
        sys.exit(1)
    try:
        calRoutine(nSteps=10) 
        calRoutine(nSteps=10, minQ=qOffDes-qInc, maxQ=qOffDes+qInc, minI=iOffDes-iInc, maxI=iOffDes+iInc) 
        calRoutine(nSteps=10, minQ=qOffDes-qInc, maxQ=qOffDes+qInc, minI=iOffDes-iInc, maxI=iOffDes+iInc) 
        calRoutine(nSteps=10, minQ=qOffDes-qInc, maxQ=qOffDes+qInc, minI=iOffDes-iInc, maxI=iOffDes+iInc) 
        calRoutine(nSteps=10, minQ=qOffDes-qInc, maxQ=qOffDes+qInc, minI=iOffDes-iInc, maxI=iOffDes+iInc, plotFlag=0) 
    finally:
        print 'Restoring initial pulse mode: %s' %(pulseMode0Str)
        pulseModePv.put(pulseMode0)
        print 'Done\n'
        msgPv.put('Done')
     
    
    
