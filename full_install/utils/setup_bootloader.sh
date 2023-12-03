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

countdown_timer

einfo "Installing GRUB bootloader to EFI System Partition"
einfo "--removable option is used to ensure that the EFI bootloader can be portable"
einfo "This creates the 'default' directory defined by the UEFI specification."
einfo "We then create a file with the default name: BOOTX64.EFI."
einfo "This ensures that the UEFI firmware will load GRUB."

countdown_timer

# Install GRUB to the EFI directory
grub-install --target=x86_64-efi --efi-directory=/efi --removable || { einfo "Failed to install GRUB"; exit 1; }
einfo "GRUB bootloader installation complete"

countdown_timer

einfo "Generating GRUB configuration file"
OS_PROBER_LINE="GRUB_DISABLE_OS_PROBER=false"
echo "$OS_PROBER_LINE" | tee -a /etc/default/grub
# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg || { einfo "Failed to generate GRUB config"; exit 1; }
einfo "GRUB configuration file generation complete"

countdown_timer

einfo "Bootloader setup complete"
