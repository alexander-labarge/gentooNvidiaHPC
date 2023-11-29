#!/bin/bash

RSYNC="/usr/bin/rsync"
OPTS="--progress --info=progress2 --verbose --recursive --links --perms --times -D --delete"
SRC="rsync://mirror.leaseweb.com/gentoo/"
#SRC="rsync://mirrors.mit.edu/gentoo-distfiles/"
DST="./gentoo-source/"

echo "Started update at" `date`
${RSYNC} ${OPTS} ${SRC} ${DST}
echo "End: "`date`
