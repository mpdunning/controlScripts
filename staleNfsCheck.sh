#!/bin/bash
#
# Checks for stale nfs mounts.

mount | sed -n "s/^.* on \(.*\) type nfs .*$/\1/p" | 
while read mount_point ; do 
    timeout 10 ls $mount_point >& /dev/null || echo "stale $mount_point" ; 
done

exit 0

