#!/bin/bash

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

# Stop on any error
set -e

einfo "Emerging necessary packages for Slurm..."
emerge --autounmask-continue --verbose sys-devel/autoconf sys-devel/automake sys-devel/libtool dev-libs/openssl sys-libs/zlib virtual/mpi dev-util/pkgconf dev-libs/json-c

# Download and unpack Slurm source tarball
einfo "Downloading and unpacking Slurm..."
wget $MIRROR_SERVER_EXTRAS_WGET_ADDRESS/slurm-23.11.0.tar.bz2
tar -xaf slurm-23.11.0.tar.bz2

# Enter the Slurm source directory
cd slurm-23.11.0

# Configure Slurm with appropriate options
einfo "Configuring Slurm..."
./configure --prefix=/usr \
            --sysconfdir=/etc/slurm \
            --enable-debug

# Compile and install Slurm
einfo "Compiling and installing Slurm..."
make -j$(nproc)
make install

# Update ldconfig for Slurm libraries
einfo "Updating ldconfig for Slurm libraries..."
ldconfig -n /usr/lib64

einfo "Slurm Version:"
slurmd --version
einfo "Slurm installation complete."
