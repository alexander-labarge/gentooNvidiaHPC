#!/bin/bash
# setup_bootloader.sh
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
einfo "Setting up GRUB for UEFI booting"
# Add GRUB UEFI support to make.conf
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
einfo "GRUB UEFI support added to make.conf"

countdown_timer

einfo "Emerging GRUB bootloader"
# Install GRUB package
emerge sys-boot/grub || { einfo "Failed to emerge GRUB"; exit 1; }

countdown_timer

einfo "Installing GRUB bootloader to EFI System Partition"
# Install GRUB to the EFI directory
grub-install --target=x86_64-efi --efi-directory=/boot/efi || { einfo "Failed to install GRUB"; exit 1; }
einfo "GRUB bootloader installation complete"

countdown_timer

einfo "Generating GRUB configuration file"
# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg || { einfo "Failed to generate GRUB config"; exit 1; }
einfo "GRUB configuration file generation complete"

countdown_timer

einfo "Bootloader setup complete"
