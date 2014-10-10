#!/bin/sh
exec /sbin/setuser root /usr/sbin/smbd -F -d 1 >> /var/log/smbd 2>&1
