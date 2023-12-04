#!/bin/bash

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

# Stop on any error
set -e

# Create munge user if not exists
if ! id "munge" &>/dev/null; then
    einfo "Creating munge user..."
    useradd -r -s /usr/sbin/nologin -G wheel munge
    einfo "Munge user created."
fi

# Install necessary packages
einfo "Emerging necessary packages with autounmask..."
emerge --autounmask-continue --verbose dev-libs/libgcrypt app-arch/bzip2 sys-libs/zlib dev-util/pkgconf
emerge --autounmask-continue --verbose sys-auth/munge
einfo "Munge Version:"
munge --version
einfo "MUNGE installation complete."
