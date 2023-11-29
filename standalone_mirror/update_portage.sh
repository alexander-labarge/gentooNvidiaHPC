#!/bin/bash

RSYNC="/usr/bin/rsync"
OPTS="--progress --info=progress2 --recursive --links --perms --times -D --delete --timeout=300 --checksum"
SRC="rsync://rsync.us.gentoo.org/gentoo-portage" 
DST="./gentoo-portage/"

echo "Started update at" `date`
${RSYNC} ${OPTS} ${SRC} ${DST}
echo "End: "`date`
