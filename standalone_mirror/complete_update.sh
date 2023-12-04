#!/bin/bash

# Date variable for reusability
TODAYS_DATE=$(date '+%Y%m%d')

# Log file location using the date variable
LOG_FILE="/mirror/gentoo/mirror-logs/UPDATE_ALL_log_${TODAYS_DATE}.log"

# Echo message with instructions to monitor the log file in yellow
echo -e "\033[1;33mTo monitor the log output, use:\033[0m"
echo -e "\033[1;33mwatch -n 2 tail -n 10 ${LOG_FILE}\033[0m"

# Function to log messages
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to check and optionally add a cron job
check_and_add_cron_job() {
    local script_path="/mirror/gentoo/update-scripts/complete_update.sh"
    local job="0 */4 * * * $script_path"

    # Check if the cron job already exists
    if crontab -l | grep -Fq "$script_path"; then
        echo -e "\033[1;33mCron job for $script_path already exists.\033[0m"
    else
        echo -e "\033[1;33mCron job for $script_path not found.\033[0m"
        read -p "Do you want to add it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            (crontab -l 2>/dev/null; echo "$job") | crontab -
            echo -e "\033[1;33mCron job added for $script_path.\033[0m"
        else
            echo -e "\033[1;33mCron job not added.\033[0m"
        fi
    fi
}

# Print header information in yellow with blue ###
HEADER_INFO="
\033[1;34m################################################################################\033[0m
\033[1;33mGentoo Linux Tree Mirror Update Script via RSYNC\033[0m
\033[1;34m################################################################################\033[0m
\033[1;33mAuthor:		La Barge, Alexander\033[0m
\033[1;33mE-mail:		alex@labarge.dev\033[0m
\033[1;33mDate:		$(date '+%d %b %Y')\033[0m
\033[1;33mVersion:	0.1.0\033[0m
\033[1;34m################################################################################\033[0m
\033[1;33m          Purpose: Complete Two Server Side (2) Tasks Below\033[0m
\033[1;34m################################################################################\033[0m
\033[1;33m          1: Update Gentoo Portage Tree via RSYNC\033[0m
\033[1;33m          2: Update Gentoo Source Files via RSYNC\033[0m
\033[1;34m################################################################################\033[0m
\033[1;33m          Official RSYNC Mirrors Only\033[0m
\033[1;34m################################################################################\033[0m
\033[1;33m          1: rsync://rsync.us.gentoo.org/gentoo-portage/\033[0m
\033[1;33m          2: rsync://mirrors.mit.edu/gentoo-distfiles/\033[0m
\033[1;34m################################################################################\033[0m
\033[1;33m          ENVIRONMENT REQUIREMENTS:\033[0m
\033[1;34m################################################################################\033[0m
\033[1;33m	    Storage Size:	   One (1) TB - EXT4 or XFS Format\033[0m
\033[1;33m	    Storage mounted at:	   /mirror\033[0m
\033[1;33m	    Directories Expected:  /mirror/gentoo/gentoo-portage/\033[0m
\033[1;33m				   /mirror/gentoo/gentoo-source/\033[0m
\033[1;33m				   /mirror/gentoo/mirror-logs/\033[0m
\033[1;33m				   /mirror/gentoo/update-scripts/\033[0m
\033[1;33m	    Main Script Location:  /mirror/gentoo/update-scripts/complete_update.sh\033[0m
\033[1;33m	    Log Files Location:    /mirror/gentoo/mirror-logs/\033[0m
\033[1;34m################################################################################\033[0m"
echo -e "$HEADER_INFO"

# Log start of the script
log_message "Script started at $(date)"

# Check the size of mirror-logs directory
LOGS_DIR="/mirror/gentoo/mirror-logs"
LOGS_DIR_SIZE_MB=$(du -sm "$LOGS_DIR" | cut -f1)
log_message "Current size of $LOGS_DIR: $LOGS_DIR_SIZE_MB MB"

# Variable to store the final size of the log directory before update
FINAL_LOGS_DIR_SIZE_MB=$LOGS_DIR_SIZE_MB

# If size is more than 100 GB, remove all but the two most recent log files
LOGS_DIR_SIZE_GB=$((LOGS_DIR_SIZE_MB / 1024))
if [ $LOGS_DIR_SIZE_GB -gt 100 ]; then
    log_message "Size exceeds 100 GB. Removing older log files..."
    # List all files, sort by date, skip the two most recent, and delete the rest
    find "$LOGS_DIR" -type f -name '*.log' | sort | head -n -2 | xargs rm -f
    # Calculate and log new storage usage
    FINAL_LOGS_DIR_SIZE_MB=$(du -sm "$LOGS_DIR" | cut -f1)
    log_message "New size of $LOGS_DIR after cleanup: $FINAL_LOGS_DIR_SIZE_MB MB"
fi

echo -e "\033[1;34m################################################################################\033[0m"
echo "Log Directory Size Limit: 100 GB/10000 MB"
echo "Starting Log Dir Size: $LOGS_DIR_SIZE_MB MB"
echo "Final Log Dir Size: $FINAL_LOGS_DIR_SIZE_MB MB"
echo "Log Directory Check Completed"
echo -e "\033[1;34m################################################################################\033[0m"
# Check for required directories
if [ ! -d "/mirror/gentoo/gentoo-portage" ] || [ ! -d "/mirror/gentoo/gentoo-source" ]; then
    log_message "ERROR: Required directories not found. Exiting."
    exit 1
fi

# RSYNC commands
RSYNC="/usr/bin/rsync"
PORTAGE_OPTS="--progress --info=progress2 --recursive --links --perms --times -D --delete --timeout=300 --checksum"
SOURCE_OPTS="--progress --info=progress2 --verbose --recursive --links --perms --times -D --delete"

PORTAGE_SRC="rsync://rsync.us.gentoo.org/gentoo-portage" 
SOURCE_SRC="rsync://mirrors.mit.edu/gentoo-distfiles/"

# Alternatively:
# SOURCE_SRC="rsync://mirror.leaseweb.com/gentoo/"

PORTAGE_DST="/mirror/gentoo/gentoo-portage/"
SOURCE_DST="/mirror/gentoo/gentoo-source/"

# Record start time
START_TIME=$(date)
log_message "Beginning updates at: $START_TIME"

# Update Gentoo Portage Tree
log_message "Starting Gentoo Portage Tree update..."
PORTAGE_START_TIME=$(date)
log_message "Start Time: $PORTAGE_START_TIME"
if ${RSYNC} ${PORTAGE_OPTS} ${PORTAGE_SRC} ${PORTAGE_DST} >> "$LOG_FILE" 2>&1; then
    PORTAGE_END_TIME=$(date)
    log_message "Gentoo Portage Tree update successful."
    log_message "End Time: $PORTAGE_END_TIME"
else
    log_message "Gentoo Portage Tree update failed."
    exit 1
fi

echo -e "\033[1;34m################################################################################\033[0m"

# Update Gentoo Source Files
log_message "Starting Gentoo Source Files update..."
SOURCE_START_TIME=$(date)
log_message "Start Time: $SOURCE_START_TIME"
if ${RSYNC} ${SOURCE_OPTS} ${SOURCE_SRC} ${SOURCE_DST} >> "$LOG_FILE" 2>&1; then
    SOURCE_END_TIME=$(date)
    log_message "Gentoo Source Files update successful."
    log_message "End Time: $SOURCE_END_TIME"
else
    log_message "Gentoo Source Files update failed."
    exit 1
fi

echo -e "\033[1;34m################################################################################\033[0m"

# Record end time
END_TIME=$(date)

# Calculate storage used
STORAGE_USED=$(du -sch /mirror/gentoo | tail -n1 | awk '{print $1}')

# Output the end time and results to log
log_message "Ended at: $END_TIME"
log_message "          RSYNCs are complete"
log_message "          Information:"
log_message "          Start Time: $START_TIME"
log_message "          End Time: $END_TIME"
log_message "          Total Storage for Gentoo: $STORAGE_USED"
echo -e "\033[1;34m################################################################################\033[0m"

# Echo path of log file for user reference
echo "Script execution details are logged in $LOG_FILE"
check_and_add_cron_job
