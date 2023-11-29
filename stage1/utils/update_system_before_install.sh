#!/bin/bash
# update_system_before_install.sh
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

# einfo "Updating world set..."
# # Update the world set
# emerge --verbose --update --deep --newuse @world
# einfo "World set updated."
# countdown_timer

einfo "System update and configuration complete."
