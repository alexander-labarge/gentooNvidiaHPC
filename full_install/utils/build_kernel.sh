#!/bin/bash

source /tmp/einfo_timer_util.sh

# Start timer for kernel installation
einfo "Starting timer for kernel installation..."
start_time=$(date +%s)
einfo "Compile Start time: $(date)"

einfo "Adding Experimental/ Bleeding Edge Kernel Source Files..."
einfo "This requires ~amd64 package unmasking."
einfo "Adding ~amd64 package unmasking..."
countdown_timer
einfo "Note: World has been rebuilt with stable packages."
einfo "Note: This is only for the kernel source files,"
einfo "the kernel itself, and NVIDIA CUDA Runtime"
einfo "These packages have been validated by the author."
countdown_timer
echo 'ACCEPT_KEYWORDS="~amd64"' >> /etc/portage/make.conf
countdown_timer
einfo "Experimental Performance Package unmasking enabled."
countdown_timer

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
# cp /tmp/kernel_config_intel_nvidia_6.6.3_2Dec23 /usr/src/linux/.config
cp /tmp/nvidia_kernel_config /usr/src/linux/.config
einfo "Kernel Config File Imported Successfully."
einfo "Kernel Source Directory: $new_kernel_dir"
einfo "Kernel Version: $kernel_ver"
einfo "Kernel Config File: /usr/src/linux/.config"
countdown_timer

einfo "Generating Kernel Make Files based on Custom Kernel Config File..."
countdown_timer
# Define the kernel source directory
kernel_src="/usr/src/linux"
# Run make oldconfig
echo "n" | make -C "$kernel_src" oldconfig
einfo "Kernel Make Files Generated Successfully."

countdown_timer

einfo "Compiling Kernel..."
countdown_timer
# Compile the kernel with the number of processors available
einfo "Compiling Kernel with $(nproc) CPU processor cores..."
make -C "$kernel_src" -j$(nproc)
einfo "Kernel Compiled Successfully."
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
einfo "End time: $(date)"
einfo "Kernel Compile took $elapsed_time seconds."

countdown_timer
einfo "Installing Kernel..."
countdown_timer
# Install the kernel
make -C "$kernel_src" install
einfo "Kernel Installed Successfully."
countdown_timer
einfo "Installing Kernel Modules..."
countdown_timer
# Install modules
make -C "$kernel_src" -j$(nproc) modules_install
einfo "Kernel Modules Installed Successfully."
countdown_timer
einfo "Generating Initramfs for early boot process..."
countdown_timer
# Generate initramfs
genkernel initramfs
einfo "Initramfs Generated Successfully."
countdown_timer
# Clean stale dependency packages
einfo "Cleaning stale dependencies..."
emerge --depclean
env-update && source /etc/profile
countdown_timer
