#!/usr/bin/env python
# Logs PV data to a file
# Someday I'll write a gui for this
# mdunning 1/2/14

from epics import PV,poll,camonitor,camonitor_clear
#from time import sleep
import datetime,os,sys,time

newpid=os.fork()  # Run as a separate (detached) process
if newpid!=0:
	sys.exit(0)

filepath='/nfs/slac/g/asta/pvLog/test/'
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

def onChanges(pvname=None, value=None, char_value=None, **kw):
    print 'PV Changed! ', pvname, char_value, time.ctime()

#PV('ASTA:PVSTATS01:INP1').add_callback(onChanges)
        
def datalog(npts,interval):
    "Logs PV data to a file; PVs must be in pvlist"
    #print 'Logging PV data to', filepath, 'as a detached process...PID is', os.getpid()
    msg1=('Dumping data to', filepath, '...PID is', str(os.getpid()))
    s=' '
    print s.join(msg1)
    #msgPV.put('Dumping data.........')
    #msgPV.put(s.join(msg1))
    #os.system("echo '' | mailx -s 'Starting pvLog' -r nlctaAutobot mdunning@slac.stanford.edu")
    filename=filepath + 'pvlog-' + str(timestamp()) + '.dat'
    with open(filename, 'w') as datafile:
        datafile.write('Timestamp ')
        for pv in pvlist:
            datafile.write(pv.pvname)
            datafile.write(' ')
        datafile.write('\n')
        os.system("timeout 2 camonitor ASTA:PVSTATS01:INP1 > filename")
        #t0 = time.time()
        #while time.time() - t0 < 0.1:
            #camonitor('ASTA:PVSTATS01:INP1',writer=datafile.write,callback=onChanges)
            #camonitor('ASTA:PVSTATS01:INP1',callback=onChanges)
            #camonitor('ASTA:PVSTATS01:INP1',writer=datafile.write)
        #camonitor_clear('ASTA:PVSTATS01:INP1')
    #msgPV.put('Data dumped')
    #filenamePV.put(filename)
    #os.system("echo '' | mailx -s 'pvLog finished' -r nlctaAutobot mdunning@slac.stanford.edu")
    
if __name__ == "__main__":
    datalog(datalogpts,dataint)

        

exit

