#!/bin/bash
# update_system_before_install.sh

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

mkdir -p "/etc/portage/package.use/zz-autounmask"
mkdir -p "/etc/portage/package.keywords/zz-autounmask"

einfo "Recompiling Portage with --oneshot... due to new use flags"
emerge --sync
# Emerge Portage with --oneshot
emerge --verbose --autounmask-continue=y --oneshot sys-apps/portage
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
COLLATE="C.UTF-8"

einfo "Configuring time zone and locale..."
# Configure time zone and locale
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "en_US ISO-8859-1" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=\"$LOCALE\"" > /etc/env.d/02locale
echo "LC_COLLATE=\"$COLLATE\"" >> /etc/env.d/02locale
env-update && source /etc/profile
einfo "Time zone and locale configuration complete."
countdown_timer

einfo "Updating world set..."
# Update the world set
emerge --verbose --update --deep --newuse @world
einfo "World set updated."
countdown_timer

einfo "System update and configuration complete."
