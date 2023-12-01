#!/bin/bash
# einfo_timer_util.sh

# Define the einfo function for the chroot environment
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
    for ((i = 3; i >= 0; i--)); do
        if [ $i -gt 0 ]; then
            echo -ne "\r\033[K\e[31mContinuing in \e[34m$i\e[31m seconds\e[0m"
        else
            echo -e "\r\033[K\e[1;34mContinuing\e[0m"
        fi
        sleep 1
    done
}