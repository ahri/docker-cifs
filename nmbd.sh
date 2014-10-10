#!/bin/sh
exec /sbin/setuser root /usr/sbin/nmbd -F -d 1 >> /var/log/nmbd 2>&1
