#!/usr/bin/env python
#
# For calibrating Beckhoff motor ADC coefficients.

import math
import sys
from time import sleep
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats
from epics import PV

args='MOTOR_PV RBV_PV START STOP N_STEPS'

def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)

if len(sys.argv) != 6:
    show_usage()
    sys.exit(1)

#motorPv='ESB:AO:SC:2531-3-15:CH1:SET:POS:MM'
motorPv = sys.argv[1]

#rbv_pv = 'ESB:AI:3162-15:CH3'
rbv_pv = sys.argv[2]

#start_pos = 0.5
start_pos = float(sys.argv[3])

#stop_pos = 10.0
stop_pos = float(sys.argv[4])

#n_steps = 5
n_steps = int(sys.argv[5])

step_list = []
rbv_list = []


class BeckhoffMotor(PV):
    """Beckhoff Motor class which inherits from pvScan Motor class."""
    def __init__(self, pvname):
        if 'ESB' in pvname:
            rbv = pvname.split(':')[0] + ':CALC:' + ':'.join(pvname.split(':')[3:5]) + ':POS:MM'
            go = pvname.split(':')[0] + ':BO:' + ':'.join(pvname.split(':')[3:5]) + ':GO:POS'
            abort = pvname.split(':')[0] + ':BO:' + ':'.join(pvname.split(':')[3:5]) + ':STOP'
            pot_rbv = rbv_pv
        else:   
            rbv = pvname.split(':')[0] + ':CALC:' + ':'.join(pvname.split(':')[2:3]) + ':POS:MM'
            go = pvname.split(':')[0] + ':BO:' + ':'.join(pvname.split(':')[2:3]) + ':GO:POS:ABS'
            abort = pvname.split(':')[0] + ':BO:' + ':'.join(pvname.split(':')[2:3]) + ':STOP'
            pot_rbv = rbv_pv
        PV.__init__(self, pvname)
        self.rbv = PV(rbv)
        self.go = PV(go)
        self.abort = PV(abort)
        self.pot_rbv = PV(pot_rbv)

    def pvWait(self, val, delta=0.005, timeout=180.0):
        """Wait until PV is near readback (or times out) to proceed."""
        try:
            count = 0
            pause = 0.2
            while self.rbv.get() != val and count < timeout/pause:
                if math.fabs(self.rbv.get() - val) <= delta: break
                sleep(pause)
                count += 1
        except TypeError:
            print "RBV is invalid for %s, pausing for %f seconds." % (self.pvname,timeout)
            sleep(timeout)

    def move(self, val, wait=True, delta=0.005, timeout=360.0):
        """Put value and press Go button."""
        PV.put(self, val)
        sleep(1)
        self.go.put(1)
        if wait:
            self.pvWait(val, delta, timeout)


motor1=BeckhoffMotor(motorPv)

#print '\n'
print 'Motor PV: ', motor1.pvname
print 'Motor step count PV: ', motor1.rbv.pvname
initial_value = motor1.get()
print 'initial value: ', initial_value
increment = (stop_pos - start_pos)/(n_steps - 1)
print 'increment: ', increment

print '\nStarting calibration scan...'
for i in range(n_steps):
    next_position = start_pos + i*increment
    motor1.move(next_position)
    sleep(1.5)
    step_position = motor1.rbv.get()
    rbv_position = motor1.pot_rbv.get()
    print '[%f %f]' % (step_position, rbv_position)
    step_list.append(step_position)
    rbv_list.append(rbv_position)
    
print '\nMoving back to initial position...'
motor1.move(initial_value)

#print 'step list: ', step_list    
#print 'rbv list: ', rbv_list

x = np.array(rbv_list)
y = np.array(step_list)
z1 = np.polyfit(x, y, 1)
z2 = np.polyfit(x, y, 2)
z3 = np.polyfit(x, y, 3)
print '\nDone:'
print '1st order fit coefficients: ', z1
print '2nd order fit coefficients: ', z2
print '3rd order fit coefficients: ', z3

slope, intercept, r_value, p_value, std_err = stats.linregress(x,y)
print 'Linear regression: slope: %f, intercept: %f, r-squared: %f' % (slope, intercept, r_value**2)
print '\n'

p1 = np.poly1d(z1)
p2 = np.poly1d(z2)
p3 = np.poly1d(z3)
xp = np.linspace(start_pos, stop_pos, 100)    
plt.plot(x, y, 'o', label='Data')
plt.plot(xp, p1(xp), '-', label='1st')
plt.plot(xp, p2(xp), '--', label='2nd')
plt.plot(xp, p3(xp), '-.', label='3rd')
#plt.xlim(0.9*step_list[0], 1.1*step_list[-1])
plt.xlim(0.9*min(rbv_list), 1.1*max(rbv_list))
#plt.ylim(0.9*rbv_list[0], 1.1*rbv_list[-1])
plt.ylim(-5, 20)
plt.legend()
plt.show()

print '\n'


