#!/bin/bash

#source /tmp/einfo_timer_util.sh
#source /tmp/install_config.sh
source einfo_timer_util.sh
source install_config.sh

# Stop on any error
set -e

einfo "Emerging necessary packages for Hashcat"

einfo "Downloading and unpacking Slurm..."
wget $MIRROR_SERVER_EXTRAS_WGET_ADDRESS/hashcat.tar.gz
tar -xzf hashcat.tar.gz


