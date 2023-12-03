#!/bin/bash
source /tmp/install_config.sh
source /tmp/einfo_timer_util.sh

einfo "Setting the hostname to $NODE_HOSTNAME"
echo "$NODE_HOSTNAME" | tee /etc/hostname

einfo "Installing network services"
emerge net-misc/networkmanager
einfo "NetworkManager installed"

einfo "Enabling NetworkManager"
systemctl enable NetworkManager
einfo "NetworkManager enabled"

einfo "Installing Chrony for time synchronization"
emerge net-misc/chrony
einfo "Chrony installed"

einfo "Enabling Chrony service"
systemctl enable chronyd.service
einfo "Chrony service enabled"

einfo "Installing bash completion for enhanced shell usability"
emerge app-shells/bash-completion
einfo "Bash completion installed"

einfo "Reloading the systemd manager configuration"
systemctl daemon-reexec
einfo "Systemd manager configuration reloaded"

einfo "Setting up the machine ID and systemd presets"
systemd-firstboot --prompt --setup-machine-id
systemctl preset-all
einfo "Machine ID and systemd presets setup complete"

einfo "System and network setup is complete."