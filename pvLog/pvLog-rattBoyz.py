#!/usr/bin/env python
# Logs PV data to a file
# mdunning 1/2/14

from epics import PV
from time import sleep
import datetime,os,sys

newpid=os.fork()  # Run as a separate (detached) process
if newpid!=0:
	sys.exit(0)

#filepath='/nfs/slac/g/nlcta/u01/nlcta/phantom/scanData/'
filepath='/home/nlcta/phantom/scanData/'  # writing to local disk is faster
datalogpts=90  # total number of PV data points to log
dataint=0.5  # pause between PV data log points


xstagerbvpv=PV('ESB:XPS1:m3:MOTR.RBV')
xspeedpv=PV('ESB:XPS4:m2:MOTR.VELO')
ystagerbvpv=PV('ESB:XPS1:m4:MOTR.RBV')
rotstagerbvpv=PV('ESB:XPS1:m6:MOTR.RBV')
foilstagerbvpv=PV('ESB:XPS4:m1:MOTR.RBV')
lasershutterpv=PV('ESB:THSC01:SHUTTER:OC')
laserstopperpv=PV('ESB:BO:2124-8:BIT5')
screenpv=PV('ESB:BO:2114-1:BIT5')
lsrpwrpv=PV('ESB:A01:ADC1:AI:CH3')
toroid0355pv=PV('ESB:A01:ADC1:AI:CH4')
toroid2150pv=PV('ESB:A01:ADC1:AI:CH5')

pvlist=[lsrpwrpv,toroid0355pv,toroid2150pv,lasershutterpv,laserstopperpv,screenpv,xspeedpv,xstagerbvpv,ystagerbvpv,rotstagerbvpv,foilstagerbvpv]
#pvlist=[xstagepv,ystagepv,rotstagepv]


##################################################################################################################


def timestamp(format=None):
    "Formatted timestamp"
    if format == 1:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S.%f"))
    else:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S"))
        
def datalog(npts,interval):
    "Logs PV data to a file; PVs must be in pvlist"
    print 'Logging PV data to', filepath, 'as a detached process'
    with open(filepath + str(timestamp()) + '.dat', 'w') as datafile:
        datafile.write('Timestamp ')
        for pv in pvlist:
            datafile.write(pv.pvname)
            datafile.write(' ')
        datafile.write('\n')
        for i in range(npts):
            datafile.write(str(timestamp(1)))
            datafile.write(' ')
            for pv in pvlist:
                datafile.write(str(pv.value))
                datafile.write(' ')
            datafile.write('\n')
            sleep(interval)
    
    
if __name__ == "__main__":
    datalog(datalogpts,dataint)

        

exit

