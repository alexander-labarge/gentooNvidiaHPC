#!/bin/bash

# Source required utility scripts
source /tmp/einfo_timer_util.sh || { echo "Failed to source /tmp/einfo_timer_util.sh"; exit 1; }
source /tmp/install_config.sh || { echo "Failed to source /tmp/install_config.sh"; exit 1; }

# Stop on any error
set -e

einfo "Emerging necessary packages for Slurm..."
emerge --autounmask-continue --verbose sys-devel/autoconf sys-devel/automake sys-devel/libtool dev-libs/openssl sys-libs/zlib dev-util/pkgconf dev-libs/json-c

# Download and unpack Slurm source tarball
einfo "Downloading and unpacking Slurm..."
wget "$MIRROR_SERVER_EXTRAS_WGET_ADDRESS/slurm-23.11.0.tar.bz2" -O /tmp/slurm-23.11.0.tar.bz2 || { einfo "Download failed"; exit 1; }
tar -xaf /tmp/slurm-23.11.0.tar.bz2 -C /tmp || { einfo "Unpacking failed"; exit 1; }

# Enter the Slurm source directory
cd /tmp/slurm-23.11.0 || { einfo "Failed to enter the Slurm source directory"; exit 1; }

# Configure Slurm with appropriate options
einfo "Configuring Slurm..."
./configure --prefix=/usr \
            --sysconfdir=/etc/slurm \
            --enable-debug || { einfo "Configuration failed"; exit 1; }

# Compile and install Slurm
einfo "Compiling and installing Slurm..."
make -j"$(nproc)" || { einfo "Compilation failed"; exit 1; }
make install || { einfo "Installation failed"; exit 1; }

# Update ldconfig for Slurm libraries
einfo "Updating ldconfig for Slurm libraries..."
ldconfig -n /usr/lib64 || { einfo "ldconfig update failed"; exit 1; }

# Verify Slurm installation
einfo "Slurm Version:"
if slurmd --version; then
    einfo "Slurm installation complete."
else
    einfo "Slurm version check failed."
    exit 1
fi
