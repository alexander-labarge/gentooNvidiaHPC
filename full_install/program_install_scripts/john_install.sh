#!/bin/bash

# Source required utility scripts
source /tmp/einfo_timer_util.sh || { echo "Failed to source /tmp/einfo_timer_util.sh"; exit 1; }
source /tmp/install_config.sh || { echo "Failed to source /tmp/install_config.sh"; exit 1; }

# Stop on any error
set -e

einfo "Emerging necessary packages for John the Ripper..."
#emerge --autounmask-continue --verbose dev-libs/openssl sys-libs/zlib app-arch/bzip2 net-libs/libpcap dev-libs/nss dev-libs/gmp app-crypt/mit-krb5

# Download and unpack John the Ripper source tarball
einfo "Downloading and unpacking John the Ripper..."
wget "$MIRROR_SERVER_EXTRAS_WGET_ADDRESS/bleeding-jumbo.zip" -O /tmp/bleeding-jumbo.zip || { einfo "Download failed"; exit 1; }
unzip /tmp/bleeding-jumbo.zip -d /tmp || { einfo "Unpacking failed"; exit 1; }

# Change to John the Ripper source directory
cd /tmp/john-bleeding-jumbo/src || { einfo "Failed to enter the John the Ripper source directory"; exit 1; }

# Configure John the Ripper with /opt/john as the installation prefix
einfo "Configuring John the Ripper..."
./configure --prefix=/opt/john --enable-mpi CFLAGS="-g -O2" LDFLAGS=-L/usr/lib CPPFLAGS=-I/usr/include || { einfo "Configuration failed"; exit 1; }

# Compile John the Ripper
einfo "Compiling John the Ripper..."
make -sj$(nproc) || { einfo "Compilation failed"; exit 1; }

# Install John the Ripper
make install || { einfo "Installation failed"; exit 1; }

# Check if installation was successful
if [ -f /opt/john/run/john ]; then
    einfo "John the Ripper installed successfully."

    # Test John the Ripper
    einfo "Testing John the Ripper..."
    /opt/john/run/john --test

    einfo "John the Ripper installation complete."
else
    einfo "John the Ripper installation failed."
    exit 1
fi
