#!/usr/bin/env python
# Logs PV data to a file
# Someday I'll write a gui for this
# mdunning 1/2/14

from epics import PV,poll
from time import sleep
import datetime,os,sys

newpid=os.fork()  # Run as a separate (detached) process
if newpid!=0:
	sys.exit(0)

filepath='/nfs/slac/g/asta/pvLog/uvDiode/'
#filepath='/home/nlcta/aVacData/'  # writing to local disk is faster
#datalogpts=60  # total number of PV data points to log
dataint=1/180.0  # pause in seconds between PV data log points
#datalogpts=2*(1/dataint)*24*3600  # total number of PV data points to log
#datalogpts=100  # total number of PV data points to log
datalogpts=PV('ASTA:PVSTATS01:INP1:NPTS').get()  # total number of PV data points to log
msgPV=PV('ASTA:PVSTATS01:INP1:MSG')
filenamePV=PV('ASTA:PVSTATS01:INP1:FILENAME')

# Add PVs here with the following form: PV('pvname')
pvlist=[PV('ASTA:PVSTATS01:INP1')]


##################################################################################################################


def timestamp(format=None):
    "Formatted timestamp"
    if format == 1:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S.%f"))
    else:
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S"))
        
def datalog(npts,interval):
    "Logs PV data to a file; PVs must be in pvlist"
    #print 'Logging PV data to', filepath, 'as a detached process...PID is', os.getpid()
    msg1=('Dumping data to', filepath, '...PID is', str(os.getpid()))
    s=' '
    print s.join(msg1)
    #msgPV.put('Dumping data.........')
    msgPV.put(s.join(msg1))
    #os.system("echo '' | mailx -s 'Starting pvLog' -r nlctaAutobot mdunning@slac.stanford.edu")
    filename=filepath + 'pvlog-' + str(timestamp()) + '.dat'
    with open(filename, 'w') as datafile:
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
            #sleep(interval)
            poll(evt=7.e-3, iot=0.1)
    msgPV.put('Data dumped')
    filenamePV.put(filename)
    #os.system("echo '' | mailx -s 'pvLog finished' -r nlctaAutobot mdunning@slac.stanford.edu")
    
if __name__ == "__main__":
    datalog(datalogpts,dataint)

        

exit

