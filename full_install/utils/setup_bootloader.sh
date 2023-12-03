#!/bin/bash
# setup_bootloader.sh

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

einfo "Setting up GRUB for UEFI booting"
# Add GRUB UEFI support to make.conf
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
einfo "GRUB UEFI support added to make.conf"

countdown_timer

einfo "Emerging GRUB bootloader"
# Install GRUB package
emerge sys-boot/grub || { einfo "Failed to emerge GRUB"; exit 1; }
OS_PROBER_LINE="GRUB_DISABLE_OS_PROBER=false"
echo "$OS_PROBER_LINE" | tee -a /etc/default/grub
countdown_timer

einfo "Installing GRUB bootloader to EFI System Partition"
# Install GRUB to the EFI directory
grub-install --target=x86_64-efi --efi-directory=/efi || { einfo "Failed to install GRUB"; exit 1; }
einfo "GRUB bootloader installation complete"

countdown_timer

einfo "Generating GRUB configuration file"
# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg || { einfo "Failed to generate GRUB config"; exit 1; }
einfo "GRUB configuration file generation complete"

countdown_timer

einfo "Bootloader setup complete"
