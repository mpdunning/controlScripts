#!/usr/bin/env python
# Logs PV data to a file; designed to be used with pvStats IOC.
# mdunning 3/21/16

from epics import PV
import epics
from time import sleep,time
import datetime,os,sys
from threading import Thread
import matplotlib.pyplot as plt
import matplotlib.dates as md

args='PV_PREFIX INPUT_NUMBER <dump|plot>'
def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)
if len(sys.argv) != 4:
    show_usage()
    sys.exit(1)

pvPrefix=sys.argv[1]
inputN=sys.argv[2]
pid=os.getpid()
        
msgPV=PV(pvPrefix + ':INP' + inputN + ':MSG')
filenamePV=PV(pvPrefix + ':INP' + inputN + ':FILENAME')
dataInt=PV(pvPrefix + ':INP' + inputN + ':DATAINT').get()
monitorTime=PV(pvPrefix + ':INP' + inputN + ':TOTALTIME').get()
caMonFlag=PV(pvPrefix + ':INP' + inputN + ':USEMONITOR').get()
#pidStatusPv=PV(pvPrefix + ':INP' + inputN + ':PIDSTATUS')

pvName=PV(pvPrefix + ':INP' + inputN + '.INP').get()
pv1=PV(pvName.split()[0])


##################################################################################################################

class Writer(object):
    def __init__(self, name, mode):
        self.file = open(name, mode)
    def __del__(self):
        self.file.close()
    def write(self, data):
        self.file.write(data + '\n')

def timestamp(format=None):
    "Formatted timestamp"
    if format == 'us':
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S.%f"))
    elif format == 'ms':
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S.%f")[:-3])
    elif format == 's':
        return(datetime.datetime.now().strftime("%Y%m%d_%H%M%S"))
    else:
        return(datetime.datetime.now().strftime("%Y%m%d"))

def dataLog():
    "Logs PV data to a file; PVs must be in pvlist"
    now=timestamp()
    if os.environ['NFSHOME']:
        filepath=os.environ['NFSHOME'] + '/pvLog/' +  now + '/'
    else:
        filepath='~/pvLog/' + now + '/'
    if not os.path.exists(filepath):
        os.makedirs(filepath)
    msg1='Dumping data to %s ,...PID is %s.' %(filepath, str(pid))
    msgPV.put(msg1)
    filename=filepath + 'pvlog-' + timestamp('s') + '.dat'
    if caMonFlag:
        writer1=Writer(filename, 'w')
        epics.camonitor(pv1.pvname, writer=writer1.write)
        sleep(monitorTime)
        epics.camonitor_clear(pv1.pvname)
    else:
        with open(filename, 'w') as datafile:
            datafile.write('%-*s %s%s' %(22, 'Timestamp', pv1.pvname, '\n'))
            npts=int(monitorTime/dataInt)
            for i in range(npts):
                start=time()
                datafile.write(str(timestamp('us')) + ' ' + str(pv1.value) + '\n')
                elapsedTime=time()-start
                if dataInt-elapsedTime > 0:
                    sleep(dataInt-elapsedTime)
                #epics.poll(evt=7.e-3, iot=0.1)
    msgPV.put('Data dumped')
    filenamePV.put(filename)

def plotData():
    filename=filenamePV.get(as_string=True)
    #print filename 
    with open(filename, 'r') as datafile:
        lines=[line.rstrip() for line in datafile]
    if 'Timestamp' in lines[0]:
        lines.pop(0)
        timeStamps=[datetime.datetime.strptime(line.split()[0],'%Y%m%d_%H%M%S.%f') for line in lines]
        data=[line.split()[1] for line in lines]
    else:
        #print lines[0].split()
        #print '_'.join(lines[0].split()[1:3])
        timeStamps=[datetime.datetime.strptime('_'.join(lines[0].split()[1:3]),'%Y-%m-%d_%H:%M:%S.%f') for line in lines]
        data=[line.split()[3] for line in lines]
    #timeStamps=md.datestr2num(timeStamps)
    #print timeStamps
    #plt.plot_date(timeStamps, data)
    #plt.gcf().autofmt_xdate()
    plt.plot(data)
    plt.show()



if __name__ == "__main__":
    if sys.argv[3] == 'dump':
        dataLog()
    elif sys.argv[3] == 'plot':
        plotData()
    else:
        show_usage()
        sys.exit(1)

        

exit

