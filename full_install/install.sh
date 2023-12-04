#!/bin/bash

chmod +x ./utils/*.sh
source ./utils/install_config.sh

# Function to print an error message in red and bold
eerror() {
    echo -e "${RED_BOLD}ERROR: $@${RESET}" >&2
}

# Set up an error trap to call eerror and exit
trap 'eerror "An error occurred. Exiting..."; exit 1' ERR
set -e

# Function Definitions
function select_drive() {
    einfo "Current disk layout:"
    lsblk
    partprobe /dev/$DRIVE
    read -p "You have selected /dev/$DRIVE for installation. Is this correct? (y/n) " answer
    case ${answer:0:1} in
        y|Y ) ;;
        * ) 
            einfo "Installation cancelled. Please rerun the script and select the correct drive."
            exit 1
            ;;
    esac
}

function configure_disks() {
    # Display drive layout
    einfo "Drive Layout:"
    lsblk /dev/$DRIVE

    # Confirm with the user before proceeding
    read -p "Do you want to proceed with formatting this drive? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        einfo "Partitioning aborted by user."
        exit 1
    fi

    einfo "Setting up partitions on /dev/$DRIVE..."

    # Start fdisk to partition the drive
    { 
        echo g; # Create a new empty GPT partition table
        for i in {1..8}; do
            echo n; # New partition
            echo $i; # Partition number
            echo ;   # Default first sector
            case $i in
                1) echo +${EFI_SIZE} ;;
                2) echo +${HOME_SIZE} ;;
                3) echo +${VAR_SIZE} ;;
                4) echo +${TMP_SIZE} ;;
                5) echo +${USR_SIZE} ;;
                6) echo +${OPT_SIZE} ;;
                7) echo +${VAR_LOG_SIZE} ;;
                8) echo ; ;; # Default last sector for the last partition
            esac
            if [ $i -eq 1 ]; then
                echo t; # Change partition type
                echo 1; # Partition type 1 (EFI System)
            fi
        done
        echo w; # Write changes
    } | fdisk /dev/$DRIVE

    # After creating all the partitions
    partprobe /dev/$DRIVE

    einfo "Disk partitioning complete."

    countdown_timer
}

function format_filesystems() {
    # Formatting the first partition (EFI) as FAT32
    einfo "Formatting EFI partition..."
    mkfs.vfat -I -F32 "/dev/${DRIVE}1"
    einfo "EFI partition formatted."

    countdown_timer

    # Assuming /home is the second partition
    einfo "Formatting /home partition..."
    mkfs.ext4 -F "/dev/${DRIVE}2"
    einfo "/home partition formatted."

    countdown_timer

    # Assuming /var is the third partition
    einfo "Formatting /var partition..."
    mkfs.ext4 -F "/dev/${DRIVE}3"
    einfo "/var partition formatted."

    countdown_timer

    # Assuming /tmp is the fourth partition
    einfo "Formatting /tmp partition..."
    mkfs.ext4 -F "/dev/${DRIVE}4"
    einfo "/tmp partition formatted."

    countdown_timer

    # Assuming /usr is the fifth partition
    einfo "Formatting /usr partition..."
    mkfs.ext4 -F "/dev/${DRIVE}5"
    einfo "/usr partition formatted."

    countdown_timer

    # Assuming /opt is the sixth partition
    einfo "Formatting /opt partition..."
    mkfs.ext4 -F "/dev/${DRIVE}6"
    einfo "/opt partition formatted."

    countdown_timer

    # Assuming /var/log is the seventh partition
    einfo "Formatting /var/log partition..."
    mkfs.ext4 -F "/dev/${DRIVE}7"
    einfo "/var/log partition formatted."

    countdown_timer

    # Assuming / is the last partition
    einfo "Formatting / partition..."
    mkfs.ext4 -F "/dev/${DRIVE}8"
    einfo "/ partition formatted."

    einfo "Filesystems formatted."

    countdown_timer
}

function mount_file_systems() {
    einfo "Mounting filesystems..."
    
    # Mount root partition
    einfo "Creating root mount point at /mnt/gentoo..."
    mkdir -p "/mnt/gentoo"
    einfo "Root mount point created."
    mount "/dev/${DRIVE}8" "/mnt/gentoo"  # Assuming root is the 8th partition
    einfo "Mounted root partition."
  
    # Mount EFI partition
    einfo "Making EFI directory... at /efi"
    mkdir -p "/mnt/gentoo/efi"
    einfo "EFI directory created."
    mount "/dev/${DRIVE}1" "/mnt/gentoo/efi"  # Assuming EFI is the 1st partition
    einfo "Mounted EFI partition."

    # Mount /home partition
    mkdir -p "/mnt/gentoo/home"
    mount "/dev/${DRIVE}2" "/mnt/gentoo/home"  # Assuming /home is the 2nd partition
    einfo "Mounted /home partition."

    # Mount /var partition
    mkdir -p "/mnt/gentoo/var"
    mount "/dev/${DRIVE}3" "/mnt/gentoo/var"  # Assuming /var is the 3rd partition
    einfo "Mounted /var partition."

    # Mount /tmp partition
    mkdir -p "/mnt/gentoo/tmp"
    mount "/dev/${DRIVE}4" "/mnt/gentoo/tmp"  # Assuming /tmp is the 4th partition
    einfo "Mounted /tmp partition."

    # Mount /usr partition
    mkdir -p "/mnt/gentoo/usr"
    mount "/dev/${DRIVE}5" "/mnt/gentoo/usr"  # Assuming /usr is the 5th partition
    einfo "Mounted /usr partition."

    # Mount /opt partition
    mkdir -p "/mnt/gentoo/opt"
    mount "/dev/${DRIVE}6" "/mnt/gentoo/opt"  # Assuming /opt is the 6th partition
    einfo "Mounted /opt partition."

    # Mount /var/log partition
    mkdir -p "/mnt/gentoo/var/log"
    mount "/dev/${DRIVE}7" "/mnt/gentoo/var/log"  # Assuming /var/log is the 7th partition
    einfo "Mounted /var/log partition."

    einfo "ALL Filesystems mounted. Getting Mounting Info..."

    countdown_timer

    einfo "Mounting Info:"
    findmnt -R -t ext4,vfat -o TARGET,SOURCE,FSTYPE /mnt/gentoo

    countdown_timer

}

function mount_system_devices() {
    einfo "Mounting necessary filesystems..."
    mount --types proc /proc /mnt/gentoo/proc
    mount --rbind /sys /mnt/gentoo/sys
    mount --make-rslave /mnt/gentoo/sys
    mount --rbind /dev /mnt/gentoo/dev
    mount --make-rslave /mnt/gentoo/dev
    mount --rbind /run /mnt/gentoo/run
    mount --make-rslave /mnt/gentoo/run
    einfo "Filesystems mounted."
    
    countdown_timer
}

# Function to download stage3
function download_stage3() {
    einfo "Downloading stage3 tarball from $LOCAL_LINUX_SOURCE_SERVER"
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR" || { eerror "Could not cd into '$TMP_DIR'"; exit 1; }

    STAGE3_RELEASES="$LOCAL_LINUX_SOURCE_SERVER/releases/$TARGET_ARCH/autobuilds/current-$STAGE3_BASENAME/"
    CURRENT_STAGE3="$(wget -qO- "$STAGE3_RELEASES" | grep -o "\"${STAGE3_BASENAME}-[0-9A-Z]*.tar.xz\"" | sort -u | head -1)"
    CURRENT_STAGE3="${CURRENT_STAGE3:1:-1}"

    if [[ -e "${CURRENT_STAGE3}.verified" ]]; then
        einfo "$STAGE3_BASENAME tarball already downloaded and verified"
    else
        einfo "Downloading $STAGE3_BASENAME tarball"
        curl -# -O "${STAGE3_RELEASES}${CURRENT_STAGE3}"
        curl -# -O "${STAGE3_RELEASES}${CURRENT_STAGE3}.DIGESTS"
        touch "${CURRENT_STAGE3}.verified"
    fi
    einfo "Stage3 tarball download complete"
    countdown_timer
}

# Function to extract stage3
function extract_stage3() {
    einfo "Extracting..."
    [[ -n $CURRENT_STAGE3 ]] || { eerror "CURRENT_STAGE3 is not set"; exit 1; }
    [[ -e "$TMP_DIR/$CURRENT_STAGE3" ]] || { einfo "stage3 file does not exist"; exit 1; }

    einfo "Extracting stage3 tarball to /mnt/gentoo"
    tar xpf "$TMP_DIR/$CURRENT_STAGE3" -C /mnt/gentoo --xattrs --numeric-owner
    einfo "Stage3 tarball extraction complete"
    countdown_timer
}

function prepare_base_system() {
    einfo "Downloading and extracting stage3 tarball..."
    download_stage3
    extract_stage3
    einfo "Base system prepared."
}

function copy_etc_dns_hosts_info() {
    einfo "Copying DNS info..."
    einfo "Using rsync with the -av options ensures that ownership and permissions are preserved during the copy operation."
    einfo "Rsyncing /etc/resolv.conf to /mnt/gentoo/etc/resolv.conf"
    rsync -av /etc/resolv.conf /mnt/gentoo/etc/
    einfo "DNS info copied."
    einfo "Copying /etc/hosts to /mnt/gentoo/etc/hosts"
    rsync -av /etc/hosts /mnt/gentoo/etc/
    einfo "Hosts file copied."
}

function configure_chroot_environment() {
    einfo "Configuring chroot environment..."

    # Create the necessary directories
    mkdir -p "$CHROOT_TMP_DIRECTORY" "$CHROOT_OPT_DIRECTORY" \
             "$CHROOT_TMP_DIRECTORY/program_installs" \
             "$CHROOT_TMP_DIRECTORY/system-connections"

    # Associative array for script paths
    declare -A script_paths=(
        [utils]="utils"
        [program_install_scripts]="program_install_scripts"
    )

    # Copy scripts function
    copy_scripts() {
        local script_dir="$1"
        local destination="$2"
        local path="$CURRENT_INSTALL_DIRECTORY/$script_dir"
        for script in "$path"/*; do
            if [ -f "$script" ]; then
                cp "$script" "$destination"
            else
                eerror "Script $script not found"
            fi
        done
    }

    # Copy scripts from both directories
    copy_scripts "${script_paths[utils]}" "$CHROOT_TMP_DIRECTORY"
    copy_scripts "${script_paths[program_install_scripts]}" "$CHROOT_TMP_DIRECTORY/program_installs"

    einfo "All Scripts Copied into Chroot Environment."
    countdown_timer

    # Display all scripts in the chroot environment
    einfo "Listing all scripts in $CHROOT_TMP_DIRECTORY and $CHROOT_TMP_DIRECTORY/program_installs:"
    ls -l "$CHROOT_TMP_DIRECTORY/"
    ls -l "$CHROOT_TMP_DIRECTORY/program_installs/"
    countdown_timer

    # Copy NetworkManager connection profiles
    copy_network_connections

    # Make all scripts executable
    make_all_scripts_executable

    # Copy DNS Hostings info and mount system devices
    copy_dns_and_mount_devices

    einfo "Chroot environment configured."
    countdown_timer    
}

function copy_network_connections() {
    einfo "Copying System Network Connections to Chroot Environment..."
    local connections_dir="/mnt/gentoo/tmp/system-connections"
    local source_dir="/etc/NetworkManager/system-connections" # Update this path

    mkdir -p "$connections_dir"
    if [ -d "$source_dir" ]; then
        cp -a "$source_dir/"* "$connections_dir/"
        einfo "NetworkManager connection profiles copied"
    else
        eerror "Source directory for NetworkManager connections not found"
    fi
    countdown_timer
}

function make_all_scripts_executable() {
    chmod +x "$CHROOT_TMP_DIRECTORY"/*.sh "$CHROOT_TMP_DIRECTORY/program_installs"/*.sh
    einfo "All scripts in $CHROOT_TMP_DIRECTORY and program_installs are now executable."
    countdown_timer
}

function copy_dns_and_mount_devices() {
    einfo "Copying DNS Info from Host to Chroot Environment..."
    copy_etc_dns_hosts_info
    einfo "DNS Hostings info copied."
    countdown_timer
}


function install_in_chroot() {

    einfo "Installing in chroot environment..."

    # Make the script executable within the chroot environment
    chmod +x "/mnt/gentoo/tmp/chroot_commands.sh"

    # Enter chroot and execute the install script
    chroot /mnt/gentoo /bin/bash -c tmp/chroot_commands.sh || {
    eerror "An error occurred during the chroot execution."
    return 1
}
    einfo "Installation in chroot environment complete."

}

function cleanup_and_reboot() {
    read -p "Do you want to unmount filesystems and cleanup? (y/n) " unmount_answer
    if [[ ${unmount_answer,,} =~ ^(yes|y)$ ]]; then
        einfo "Unmounting filesystems..."
        if umount -l /mnt/gentoo/dev{/shm,/pts,} && umount -R /mnt/gentoo; then
            einfo "Filesystems unmounted successfully."
        else
            eerror "Failed to unmount some filesystems."
            return 1
        fi
    else
        einfo "Skipping unmounting."
    fi

    read -p "Do you want to reboot now, re-enter chroot, or exit? (reboot/chroot/exit) " action
    case ${action,,} in
        reboot )
            einfo "Rebooting..."
            reboot
        ;;
        chroot )
            einfo "Re-entering chroot environment..."
            chroot /mnt/gentoo /bin/bash
        ;;
        * )
            einfo "Exiting without reboot. You can reboot manually later."
        ;;
    esac
    einfo "System cleanup complete."
}


function install_gentoo() {

    source $CURRENT_INSTALL_DIRECTORY/utils/einfo_timer_util.sh

    einfo "Hight Performance Computing Gentoo Linux Nvidia GPU Automated Linux Installer"
    einfo "POC: La Barge, Alexander"
    einfo "Date: $(date '+%e %b %Y')"
    einfo "Version: 0.1.0"

    countdown_timer

    einfo "STEP 1: SELECT DRIVE"
    select_drive

    einfo "STEP 2: CONFIGURE DISKS"
    configure_disks

    einfo "STEP 3: FORMAT FILESYSTEMS"
    format_filesystems

    einfo "STEP 4: MOUNT FILESYSTEMS"
    mount_file_systems

    einfo "STEP 5: PREPARE BASE SYSTEM"
    prepare_base_system

    einfo "STEP 6: CONFIGURE CHROOT ENVIRONMENT"
    configure_chroot_environment

    einfo "STEP 7: MOUNT SYSTEM DEVICES"
    mount_system_devices

    einfo "STEP 8: BEGIN INSTALLATION IN CHROOT"
    install_in_chroot

    einfo "STEP 9: CLEANUP AND REBOOT"
    cleanup_and_reboot
}

install_gentoo
