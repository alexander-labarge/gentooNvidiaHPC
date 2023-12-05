#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Get the currently running kernel version
current_kernel=$(uname -r)

# Go to the boot directory
cd /boot

# Delete all kernel files except for those matching the current kernel version
for file in vmlinuz-* System.map-* config-* initramfs-*.img; do
    if [[ ! $file =~ $current_kernel ]]; then
        echo "Deleting $file"
        rm -f "$file"
    fi
done

echo "Kernel cleanup complete."
