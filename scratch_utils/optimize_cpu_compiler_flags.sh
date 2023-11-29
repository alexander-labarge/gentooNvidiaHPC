#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Backing up make.conf # 2..."
cp /etc/portage/make.conf /etc/portage/make.conf.bak2

echo "Updating make.conf with optimized CPU flags..."
optimized_flags=$(gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1 | sed -n 's/.*-march=\([a-z]*\)/-march=\1/p' | sed 's/-dumpbase null//')

if [ -z "$optimized_flags" ]; then
    echo "Failed to extract optimized CPU flags"
    exit 1
fi

sed -i "/^COMMON_FLAGS/c\COMMON_FLAGS=\"-O2 -pipe $optimized_flags\"" /etc/portage/make.conf
sed -i 's/COMMON_FLAGS="\(.*\)"/COMMON_FLAGS="\1"/;s/  */ /g' /etc/portage/make.conf

# Assign MAKEOPTS automatically
num_cores=$(nproc)
makeopts_value=$((num_cores + 1))

if grep -q "^MAKEOPTS" /etc/portage/make.conf; then
    sed -i "/^MAKEOPTS/c\MAKEOPTS=\"-j$makeopts_value\"" /etc/portage/make.conf
else
    echo "MAKEOPTS=\"-j$makeopts_value\"" >> /etc/portage/make.conf
fi

echo "make.conf has been updated successfully."

echo "Flags added were: $optimized_flags"
echo "MAKEOPTS has been set to: -j$makeopts_value"