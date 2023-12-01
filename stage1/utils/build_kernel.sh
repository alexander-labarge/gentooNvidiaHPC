#!/bin/bash

source ./einfo_timer_util.sh

# Start timer for kernel installation
einfo "Starting timer for kernel installation..."
start_time=$(date +%s)
einfo "Compile Start time: $(date)"

# Emerge required packages
einfo "Emerging Linux Kernel Source Files."
countdown_timer

einfo "Installing Linux Firmware..."
countdown_timer
emerge --verbose sys-kernel/linux-firmware

einfo "Installing Intel Microcode..."
countdown_timer
emerge --verbose sys-firmware/intel-microcode

einfo "Installing Gentoo Sources..."
countdown_timer
emerge --verbose sys-kernel/gentoo-sources

einfo "Installing Genkernel for Bootloader Integration..."
countdown_timer
emerge --verbose sys-kernel/genkernel

einfo "Packages emerged successfully."

# Compile Kernel
einfo "Compiling Kernel..."
countdown_timer

kernel_dir="/usr/src"

# Find directories starting with 'linux-', sort them, and get the last one (latest version)
latest_kernel=$(ls -d ${kernel_dir}/linux-* | sort -V | tail -n 1)

# Extract kernel version from the directory name and define the new directory name
# This line removes the 'linux-' prefix and the '-gentoo-r1' suffix
kernel_ver=$(basename "$latest_kernel" | sed -e 's/linux-//' -e 's/-gentoo-r1//')
new_kernel_dir="${kernel_dir}/linux-${kernel_ver}-deathstar-amd64"

# Rename the latest kernel directory
mv "$latest_kernel" "$new_kernel_dir"

# Create or update the symlink for the new kernel directory
ln -sfn "$new_kernel_dir" "${kernel_dir}/linux"

einfo "Symlink created for $(basename "$new_kernel_dir")"

# Import Custom Kernel Paramater Config File
countdown_timer
einfo "Importing NVIDIA GPU High Performance Oriented Kernel Config File..."
cp /tmp/nvidia_kernel_config /usr/src/linux/.config
einfo "Kernel Config File Imported Successfully."

# Define the kernel source directory
kernel_src="/usr/src/linux"

# Run make oldconfig
echo "n" | make -C "$kernel_src" oldconfig

# Compile the kernel with the number of processors available
make -C "$kernel_src" -j$(nproc)

# Install the kernel
make -C "$kernel_src" install

# Install modules
make -C "$kernel_src" modules_install

# Calculate and display the time taken
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
einfo "Kernel Compile Complete."
einfo "End time: $(date)"
einfo "Kernel installation took $elapsed_time seconds."

# Clean stale dependency packages
einfo "Cleaning stale dependencies..."
emerge --depclean
env-update && source /etc/profile
countdown_timer
