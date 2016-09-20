#!/bin/bash
#
# closeVacValves.sh: closes all beamline vac valves thru SCP
# M. Dunning 9/2/13

args="--open | --close"

function show_usage {
    echo "Usage: $0 $args"
}

if [ $# -ne 1 ]; then
    show_usage
    exit 1
fi

sleepTime=0.1
valveList="320 490 1150 1340 1505 2085"

if [ "$1" == "--open" ]; then
    action=1
elif [ "$1" == "--close" ]; then
    action=2
else
    show_usage
    echo "Argument must be '--open' or '--close'"
    exit 1
fi

for valve in $valveList; do
    caput TA01:VACV:$valve:VALVE $action
    sleep $sleepTime
done



exit 0

