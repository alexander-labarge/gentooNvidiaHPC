#!/bin/bash
source /tmp/install_config.sh
source /tmp/einfo_timer_util.sh

einfo "Re-executing the systemd manager to ensure it's up to date"
systemctl daemon-reexec

einfo "Setting the hostname to $NODE_HOSTNAME"
echo "$NODE_HOSTNAME" | tee /etc/hostname

einfo "Installing NetworkManager for network management"
emerge --verbose --autounmask-continue=y net-misc/networkmanager

einfo "Enabling NetworkManager service to start at boot"
systemctl enable NetworkManager

einfo "Re-executing the systemd manager for the second time"
systemctl daemon-reexec

einfo "Copying NetworkManager connection profiles"
CONNECTIONS_DIR="/etc/NetworkManager/system-connections"
SOURCE_DIR="/tmp/system-connections" # Update this path

if [ -d "$SOURCE_DIR" ]; then
    cp -a "$SOURCE_DIR/"* "$CONNECTIONS_DIR/"
    chmod 600 $CONNECTIONS_DIR/*.nmconnection
    einfo "NetworkManager connection profiles copied"
else
    eerror "Source directory for NetworkManager connections not found"
fi

einfo "Setting up the machine ID for systemd"
systemd-machine-id-setup

einfo "Running systemd-firstboot to configure basic system settings"
systemd-firstboot --locale=en_US.UTF-8 --timezone=America/New_York --hostname="$NODE_HOSTNAME" --root-password="$DEFAULT_USER_PASSWORD"

einfo "Applying default system service presets"
systemctl preset-all

einfo "Setting system language to en_US.UTF-8"
LANG="en_US.utf8"
echo "LANG=en_US.utf8" | tee /etc/locale.conf

einfo "Updating environment variables and sourcing profile"
env-update && source /etc/profile

einfo "Adding $NODE_USERNAME to the systemd-journal group"
gpasswd -a "$NODE_USERNAME" systemd-journal

einfo "Applying default system service presets for the second time"
systemctl preset-all

einfo "Installing Chrony for time synchronization"
emerge --verbose --autounmask-continue=y net-misc/chrony
einfo "Chrony installed"

einfo "Enabling Chrony service for automatic time synchronization"
systemctl enable chronyd.service
einfo "Chrony service enabled"

einfo "Installing bash completion for enhanced shell usability"
emerge --verbose --autounmask-continue=y app-shells/bash-completion
einfo "Bash completion installed"

einfo "System and network setup is complete."
