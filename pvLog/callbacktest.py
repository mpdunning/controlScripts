#!/usr/bin/env python

from time import sleep
import epics

def onChanges(pvname=None, value=None, char_value=None, **kw):
    print list(value)

pv1 = epics.PV('GUN:AS01:1:GN1:RWAV')
pv1.add_callback(onChanges)

sleep(3)

pv1.remove_callback(onChanges)

