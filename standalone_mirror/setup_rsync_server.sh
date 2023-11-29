#!/bin/bash

# Create and write configuration to /etc/rsyncd.conf
sudo tee /etc/rsyncd.conf <<'EOF'
# Local Mirror For All Linux Files
uid = nobody
gid = nogroup
use chroot = yes
max connections = 15
pid file = /var/run/rsyncd.pid
motd file = /etc/rsync/rsyncd.motd
log file = /var/log/rsync.log
transfer logging = yes
log format = %t %a %m %f %b
syslog facility = local3
timeout = 300

# to test: rsync rsync://xxx.xxx.xx.xxx/typhon-portage
[typhon-portage]
path = /mirror/gentoo/gentoo-portage/
comment = [U//FOUO] Linux Portage tree mirror
exclude = distfiles
EOF

# Start the rsync service
sudo systemctl start rsync

# To ensure the rsync service is enabled to start on boot
sudo systemctl enable rsync
