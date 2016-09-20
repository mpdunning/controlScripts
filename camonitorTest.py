#!/usr/bin/env python

import epics, time, sys
from threading import Thread

class Writer(object):
    def __init__(self, name, mode):
        self.file = open(name, mode)
    def __del__(self):
        self.file.close()
    def write(self, data):
        self.file.write(data + '\n')

class PvMonitor(Writer):
    def __init__(self, pvList, filename, monitorTime=2):
        Writer.__init__(self, filename, 'w')
        pvs=[[] for x in range(len(pvList))]
        self.pvList=pvList
        self.filename=filename
        self.monitorTime=monitorTime
    def monitor(self):
        for pv in self.pvList:
            epics.camonitor(pv, writer=self.write)
        time.sleep(self.monitorTime)
        for pv in self.pvList:
            epics.camonitor_clear(pv)

#class PvMonitor2():
#    def __init__(self, pvname, monitorTime=2):
#        self.pvname=pvname
#        self.monitorTime=monitorTime
#        self.vals=[]
#    def saver(self, string):
#        self.vals.append(string)
#    def monitor(self):
#        epics.camonitor(self.pvname, writer=self.saver)
#        time.sleep(self.monitorTime)
#        epics.camonitor_clear(self.pvname)
        
class PvMonitor2():
    def __init__(self, pvList, filename, monitorTime=2, show=False):
        self.pvList=pvList
        self.filename=filename
        self.monitorTime=monitorTime
        self.show=show
        self.vals=[]
    def saver(self, string):
        self.vals.append(string)
    def monitor(self):
        for pv in self.pvList:
            epics.camonitor(pv, writer=self.saver)
        time.sleep(self.monitorTime)
        for pv in self.pvList:
            epics.camonitor_clear(pv)
        pvs=[[] for i in range(len(pvList))]
        for val in self.vals:
            for i in xrange(len(self.pvList)):
                if self.pvList[i] in val:
                    pvs[i].append(val)
        lengths=[len(item) for item in pvs]
        lmin=min([len(item) for item in pvs])
        lmax=max([len(item) for item in pvs])
        with open(self.filename, 'w') as datafile:
            #try:
            for j in range(0,10):
                for i in range(len(self.pvList)):
                    print i, j, len(pvs[i]), pvs[i][j]
                    if j < len(pvs[i]):
                        if self.show: sys.stdout.write(pvs[i][j] + ' ')
                    #    datafile.write(pvs[i][j] + ' ')
                    #if self.show: sys.stdout.write('\n')
                    #datafile.write('\n')
            #except IndexError:
            #    pass

        
dataFile='camonitorTest.dat'
pvList=['13PS10:Stats1:Total_RBV', 'ESB:TUNNEL_EAST:HUMIDITY', 'ESB:AI:3314F-10:CH1']
pvmon1=PvMonitor2(pvList, dataFile, 5, show=True)
pvmon1.monitor()

##pvs=[None]
#pvs=range(len(pvList))
#vals=[[] for x in range(len(pvList))]
#threads=range(len(pvList))
#for i in range(len(pvList)):
#    pvs[i]=PvMonitor2(pvList[i], 1)
#    threads[i]=Thread(target=pvs[i].monitor(), args=())
#    threads[i].start()
#print pvs
#print threads
#
#for i in range(len(pvList)):
#    threads[i].join()
#    vals[i].append(pvs[i].vals)
#    print vals[i][0][1]

#def monitorPVs(pvList, monitorTime, writer=None):
#    for pv in pvList:
#        epics.camonitor(pv, writer=writer)
#    time.sleep(monitorTime)
#    for pv in pvList:
#        epics.camonitor_clear(pv)
#
#dataFile='camonitorTest.dat'
#writer1=Writer(dataFile, 'w')
#pvList=['ADC:AS01:13:V', 'ADC:AS01:14:V', 'ADC:AS01:15:V']
#
#monitorPVs(pvList, 0.3, writer1.write)
#
#pvs=[[] for x in range(len(pvList))]
#
#with open(dataFile, 'r') as datafile: 
#    lines=[line.rstrip() for line in datafile] 
#    for line in lines:
#        for i in xrange(len(pvList)):
#            if pvList[i] in line:
#                pvs[i].append(line)
#
#lmin=min([len(item) for item in pvs])
#
#dataFile2='camonitorTest2.dat'
#with open(dataFile2, 'w') as datafile:
#    for j in range(lmin):
#        for i in range(len(pvList)):
#            datafile.write(pvs[i][j] + ' ')
#        datafile.write('\n')

