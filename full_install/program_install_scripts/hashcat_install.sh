#!/bin/bash

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

# Stop on any error
set -e

einfo "Emerging necessary packages for Hashcat"
countdown_timer
emerge --verbose --autounmask-continue=y  app-arch/unrar
emerge --verbose --autounmask-continue=y app-arch/p7zip

einfo "Downloading and unpacking Slurm..."
wget $MIRROR_SERVER_EXTRAS_WGET_ADDRESS/hashcat.tar.gz -O /tmp/hashcat.tar.gz
tar -xzf /tmp/hashcat.tar.gz
make -C /tmp/hashcat -j$(nproc)
make -C /tmp/hashcat install

einfo "Checking to ensure Hashcat was installed"
hashcat --version
countdown_timer
