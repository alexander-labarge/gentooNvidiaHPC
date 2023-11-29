#!/bin/bash
# nvidia_driver_install.sh
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
# Install Nvidia drivers
einfo "Installing Nvidia drivers..."
emerge --verbose x11-drivers/nvidia-drivers
einfo "Nvidia drivers installation complete."
countdown_timer

# Rebuild kernel modules for Nvidia
einfo "Rebuilding kernel modules for Nvidia..."
emerge --verbose @module-rebuild
einfo "Kernel modules for Nvidia have been rebuilt."
countdown_timer

# Regenerate GRUB configuration
einfo "Regenerating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg
einfo "GRUB configuration regeneration complete."
countdown_timer