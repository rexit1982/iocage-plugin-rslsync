#!/bin/sh

#vars
ver="2.6.4"
dlurl="https://download-cdn.resilio.com/${ver}/FreeBSD-x64/resilio-sync_freebsd_x64.tar.gz"
piddir="/var/run/rslsync"
dbdir="/var/db/rslsync"
bindir="/usr/local/bin"

# Enable the service
chmod u+x /usr/local/etc/rc.d/rslsync
sysrc -f /etc/rc.conf rslsync_enable="YES"

# Set rc.conf values for plugin editable values when we get around to it.
sysrc -f /etc/rc.conf rslsync_user="rslsync"
sysrc -f /etc/rc.conf rslsync_group="rslsync"

#create user
pw user add rslsync -c rslsync -d /nonexistent -s /usr/bin/nologin
#create directories - set perms
mkdir -p $bindir
mkdir -p $piddir
chown -R rslsync:rslsync $piddir
mkdir -p $dbdir
chown -R rslsync:rslsync $dbdir

#download and extract the bin
cd $bindir
fetch $dlurl -o rslsync.tar.gz
tar -xvf rslsync.tar.gz
rm rslsync.tar.gz
rm LICENSE.TXT
chmod u+x rslsync

#create base config file
$bindir/rslsync --nodaemon --storage $dbdir --dump-sample-config > /usr/local/etc/rslsync.conf

echo "Default web port: 8888" >> /root/PLUGIN_INFO
echo "Service user and group: rslsync" >> /root/PLUGIN_INFO

#Thank you Asigra via ConorBeh for this hack
echo "Find Network IP"
#Very Dirty Hack to get the ip for dhcp, the problem is that IOCAGE_PLUGIN_IP doesent work on DCHP clients
netstat -nr | grep lo0 | grep -v '::' | grep -v '127.0.0.1' | awk '{print $1}' | head -n 1 > /root/dhcpip
IP=`cat /root/dhcpip`

echo "------Plugin Info------"
echo "Access Web interface to configure http://${IP}:8888"
echo "Service user and group: rslsync" 
# Start the service
service rslsync start 2>/dev/null
