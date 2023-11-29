#!/bin/bash
# kernel_install_fstab.sh

function einfo() {
    local blue='\e[1;34m'   # Light blue
    local yellow='\e[1;33m' # Yellow
    local red='\e[1;31m'    # Red
    local reset='\e[0m'     # Reset text formatting

    echo -e "${red}----------------------------------------------------------------------------${reset}"
    echo -e "${blue}[${yellow}$(date '+%Y-%m-%d %H:%M:%S')${blue}] $1${reset}"
    echo -e "${red}----------------------------------------------------------------------------${reset}"
}

function countdown_timer() {
    for ((i = 1; i >= 0; i--)); do
        if [ $i -gt 1 ]; then
            echo -ne "\r\033[K\e[31mContinuing in \e[34m$i\e[31m seconds\e[0m"
        elif [ $i -eq 1 ]; then
            echo -ne "\r\033[K\e[31mContinuing in 1 second\e[0m"
            sleep 1
        else
            echo -e "\r\033[K\e[1;34mContinuing\e[0m"
        fi
        sleep 1
    done
}

# Start timer for kernel installation
einfo "Starting timer for kernel installation..."
start_time=$(date +%s)
einfo "Compile Start time: $(date)"
# Emerge required packages
einfo "Emerging required packages..."
emerge sys-kernel/linux-firmware sys-firmware/intel-microcode sys-kernel/installkernel-gentoo sys-kernel/gentoo-kernel

# Calculate and display the time taken
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
einfo "Kernel Compile Complete."
einfo "End time: $(date)"
einfo "Kernel installation took $elapsed_time seconds."

countdown_timer

# Clean stale dependency packages
einfo "Cleaning stale dependencies..."
emerge --depclean
env-update && source /etc/profile

countdown_timer

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
