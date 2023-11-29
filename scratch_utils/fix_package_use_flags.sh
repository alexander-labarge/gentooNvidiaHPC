#!/bin/bash

# Define the necessary USE flag changes
USE_CHANGES=(
    ">=media-libs/libglvnd X"
    ">=x11-libs/cairo X"
    "sys-kernel/installkernel-gentoo grub"
)
emerge app-portage/cpuid2cpuflags
# Display the Processors Available USE Flags with cpuid2cpuflags
cpuid2cpuflags
# Echo the contents of the CPU Flags to the package.use file
echo "*/* $(cpuid2cpuflags)" | tee /etc/portage/package.use/00cpu-flags

# Check if the package.use directory exists
if [ ! -d /etc/portage/package.use ]; then
    echo "Creating /etc/portage/package.use directory..."
    mkdir -p /etc/portage/package.use
fi

# Apply the USE flag changes
for change in "${USE_CHANGES[@]}"; do
    echo "${change}" >> /etc/portage/package.use/custom
done

