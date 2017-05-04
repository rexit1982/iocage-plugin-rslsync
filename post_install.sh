#!/bin/sh

# Enable the service
sysrc -f /etc/rc.conf btsync_enable="YES"

# Start the service
service btsync start 2>/dev/null
