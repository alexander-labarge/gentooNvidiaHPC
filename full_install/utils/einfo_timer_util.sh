#!/bin/bash
# einfo_timer_util.sh

# Define the einfo function for the chroot environment
function einfo() {
    local light_green='\e[1;32m'  # Light green
    local yellow='\e[1;33m'       # Yellow
    local red='\e[1;31m'          # Red
    local reset='\e[0m'           # Reset text formatting
    local hostname=$(hostname)
    local current_datetime=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="/opt/install-log-${hostname}-$(date '+%Y-%m-%d').log"

    echo -e "${red}------------------------------------------------------------------------------------------------------------${reset}"
    echo -e "${light_green}[${yellow}${current_datetime}${light_green}] $1${reset}"
    echo -e "${red}------------------------------------------------------------------------------------------------------------${reset}"

    # Append the log message to the log file
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "/tmp/$log_file"
}

function countdown_timer() {
    for ((i = 3; i >= 0; i--)); do
        if [ $i -gt 0 ]; then
            echo -ne "\r\033[K\e[31mContinuing in \e[32m$i\e[31m seconds\e[0m"
        else
            echo -e "\r\033[K\e[1;32mContinuing\e[0m"
        fi
        sleep 1
    done
}
