#!/bin/bash

# Source required utility scripts
source /tmp/einfo_timer_util.sh || { echo "Failed to source /tmp/einfo_timer_util.sh"; exit 1; }
source /tmp/install_config.sh || { echo "Failed to source /tmp/install_config.sh"; exit 1; }

# Stop on any error
set -e

einfo "John Needs Libregexgen to be complete which needs to be built with Clang"
einfo "Emerging necessary packages for Clang..."

countdown_timer

#emerge --verbose --autounmask-continue=y sys-devel/clang || { einfo "Clang installation failed"; exit 1; }
#emerge --verbose --autounmask-continue=y dev-python/setuptools || { einfo "Python Setuptools installation failed"; exit 1; }

einfo "Downloading and unpacking Libregexgen..."

wget "$MIRROR_SERVER_EXTRAS_WGET_ADDRESS/regexgen.zip" -O /tmp/regexgen.zip || { einfo "Download failed"; exit 1; }

unzip /tmp/regexgen.zip -d /tmp || { einfo "Unpacking failed"; exit 1; }

# Find Python version
PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)

# Find Python library
PYTHON_LIB_PATH=$(find /usr/lib64 -name "libpython$PYTHON_VERSION.so" -print -quit)

# Find Python header
PYTHON_HEADER_PATH=$(find /usr/include -path "*python$PYTHON_VERSION/Python.h" -print -quit)

# Check if Python library and header were found
if [ -z "$PYTHON_LIB_PATH" ] || [ -z "$PYTHON_HEADER_PATH" ]; then
    echo "Python library or header files not found."
    exit 1
fi

# Extract Python include directory
PYTHON_INCLUDE_DIR=$(dirname $PYTHON_HEADER_PATH)
PYTHON_LIBRARY=$PYTHON_LIB_PATH

echo "Found Python library: $PYTHON_LIBRARY"
echo "Found Python headers: $PYTHON_INCLUDE_DIR"

# Navigate to the rexgen source directory
cd /tmp/rexgen-master/src

sed -i 's/find_library(PYTHONLIBS REQUIRED )/find_package(PythonLibs REQUIRED)/' /tmp/rexgen-master/src/librexgen/python/CMakeLists.txt

# Run CMake with the specified Python paths and enable Python module
cmake -DUSE_PYTHON=ON -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR -DPYTHON_LIBRARY=$PYTHON_LIBRARY ../

cd /tmp/rexgen-master/src/ && make || { einfo "Failed to Install Rexgen"; exit 1; }
make install || { einfo "Failed to Install Rexgen"; exit 1; }
ldconfig

einfo "Install Libregexgen complete"

einfo "Testing Rexgen"
rexgen --version

countdown_timer

einfo "Emerging necessary packages for John the Ripper..."
emerge --verbose --autounmask-continue=y dev-libs/opencl-icd-loader dev-util/opencl-headers dev-libs/openssl sys-libs/zlib app-arch/bzip2 net-libs/libpcap dev-libs/nss dev-libs/gmp app-crypt/mit-krb5

# Target CPU ......................................... x86_64 AVX2, 64-bit LE
# AES-NI support ..................................... run-time detection
# Target OS .......................................... linux-gnu
# Cross compiling .................................... no
# Legacy arch header ................................. x86-64.h

# Optional libraries/features found:
# Memory map (share/page large files) ................ yes
# Fork support ....................................... yes
# OpenMP support ..................................... yes (not for fast formats)
# OpenCL support ..................................... no
# Generic crypt(3) format ............................ yes
# OpenSSL (many additional formats) .................. yes
# libgmp (PRINCE mode and faster SRP formats) ........ yes
# 128-bit integer (faster PRINCE mode) ............... yes
# libz (7z, pkzip and some other formats) ............ yes
# libbz2 (7z and gpg2john bz2 support) ............... yes
# libpcap (vncpcap2john and SIPdump) ................. no
# Non-free unrar code (complete RAR support) ......... yes
# librexgen (regex mode, see doc/README.librexgen) ... no
# OpenMPI support (default disabled) ................. yes
# Experimental code (default disabled) ............... no
# ZTEX USB-FPGA module 1.15y support ................. no

# Install missing libraries to get any needed features that were omitted.

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
make -s clean || { einfo "Cleaning failed"; exit 1; }
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
