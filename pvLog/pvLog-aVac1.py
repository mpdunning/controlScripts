#!/usr/bin/env python
# Logs PV data to a file
# Someday I'll write a gui for this
# mdunning 1/2/14

from epics import PV
from time import sleep
import datetime,os,sys

newpid=os.fork()  # Run as a separate (detached) process
if newpid!=0:
	sys.exit(0)

#filepath='/nfs/slac/g/nlcta/u01/nlcta/phantom/scanData/'
filepath='/home/nlcta/aVacData/'  # writing to local disk is faster
#datalogpts=60  # total number of PV data points to log
dataint=1  # pause in seconds between PV data log points
datalogpts=2*(1/dataint)*24*3600  # total number of PV data points to log

# Add PVs here with the following form: PV('pvname')
pvlist=[PV('ESB:AVAC01:I:CH1'),PV('ESB:AVAC01:I:CH2'),PV('ESB:AVAC01:I:CH3'),PV('ESB:AVAC01:I:CH4')]


##################################################################################################################


def timestamp(format=None):
    "Formatted timestamp"
    if format == 1:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S.%f"))
    else:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S"))
        
def datalog(npts,interval):
    "Logs PV data to a file; PVs must be in pvlist"
    print 'Logging PV data to', filepath, 'as a detached process...PID is', os.getpid()
    os.system("echo '' | mailx -s 'Starting pvLog' -r nlctaAutobot mdunning@slac.stanford.edu")
    with open(filepath + 'pvlog-' + str(timestamp()) + '.dat', 'w') as datafile:
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
    os.system("echo '' | mailx -s 'pvLog finished' -r nlctaAutobot mdunning@slac.stanford.edu")
    
if __name__ == "__main__":
    datalog(datalogpts,dataint)

        

exit

