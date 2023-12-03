#!/bin/bash
# kernel_install_fstab.sh

source /tmp/einfo_timer_util.sh

# # Start timer for kernel installation
# einfo "Starting timer for kernel installation..."
# start_time=$(date +%s)
# einfo "Compile Start time: $(date)"
# # Emerge required packages
# einfo "Emerging required packages..."
# emerge sys-kernel/linux-firmware sys-firmware/intel-microcode sys-kernel/installkernel-gentoo sys-kernel/gentoo-kernel

# # Calculate and display the time taken
# end_time=$(date +%s)
# elapsed_time=$((end_time - start_time))
# einfo "Kernel Compile Complete."
# einfo "End time: $(date)"
# einfo "Kernel installation took $elapsed_time seconds."

# countdown_timer

# # Clean stale dependency packages
# einfo "Cleaning stale dependencies..."
# emerge --depclean
# env-update && source /etc/profile

# countdown_timer

# Backup and generate fstab
einfo "Backing up and generating fstab..."
cp /etc/fstab /etc/fstab.backup

# Generate fstab
emerge --verbose sys-fs/genfstab
genfstab -U / > /etc/fstab

einfo "Fstab generation complete."
einfo "Contents of /etc/fstab:"
cat /etc/fstab

countdown_timer
