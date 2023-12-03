#!/bin/bash
# nvidia_driver_install.sh

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

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