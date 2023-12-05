#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Step 1: Emerge the distribution kernel sources
echo "Emerging the latest distribution kernel sources..."
emerge --verbose --autounmask-continue=y sys-kernel/gentoo-sources

# Ensure genkernel is installed
echo "Ensuring genkernel is installed..."
emerge --verbose --autounmask-continue=y sys-kernel/genkernel

# Step 2: Compile and install the kernel using genkernel
echo "Compiling and installing the kernel..."
genkernel all --microcode=none

# Step 3: Rebuild NVIDIA modules
echo "Rebuilding NVIDIA modules..."
emerge --ask @module-rebuild

# Step 4: Update GRUB configuration
echo "Updating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg

# Step 5: Install EFI x64 with target /efi
echo "Installing EFI x64 with target /efi..."
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB

# Completion message
echo "All operations completed successfully!"
