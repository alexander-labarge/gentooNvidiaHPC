#!/bin/bash
# update_system_before_install.sh

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

einfo "Recompiling Portage with --oneshot... due to new use flags"
emerge --sync
# Emerge Portage with --oneshot
emerge --oneshot sys-apps/portage
einfo "Portage updated"
countdown_timer

einfo "Updating Portage tree..."
# Update the Portage tree
emerge --sync
einfo "Portage tree updated."
countdown_timer

# Set your time zone and locale here
TIMEZONE="America/New_York" # Replace with your time zone
LOCALE="en_US.UTF-8" # Replace with your locale

einfo "Configuring time zone and locale..."
# Configure time zone and locale
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
sed -i 's/# \($LOCALE\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=\"$LOCALE\"" > /etc/env.d/02locale
env-update && source /etc/profile
einfo "Time zone and locale configuration complete."
countdown_timer

einfo "Updating world set..."
# Update the world set
emerge --verbose --update --deep --newuse @world
einfo "World set updated."
countdown_timer

einfo "System update and configuration complete."
