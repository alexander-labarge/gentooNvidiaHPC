#!/bin/bash
# Error handling
# Define ANSI escape codes for red and bold text
RED_BOLD='\033[1;31m'
RESET='\033[0m'  # Reset text formatting

# Function to print an error message in red and bold
eerror() {
    echo -e "${RED_BOLD}ERROR: $@${RESET}" >&2
}

# Set up an error trap to call eerror and exit
trap 'eerror "An error occurred. Exiting..."; exit 1' ERR
set -e

# Drive identifier
DRIVE="sda"

# Predefined partition sizes
EFI_SIZE="1G"
HOME_SIZE="100G"
VAR_SIZE="100G"
TMP_SIZE="100G"
USR_SIZE="100G"
OPT_SIZE="100G"
VAR_LOG_SIZE="100G"

# System configuration
TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"
NODE_HOSTNAME="deathstar-tower"
DEFAULT_USER="skywalker"
GROUPS_TO_ADD="wheel"

# Server and network configuration
MIRROR_SERVER_IP="192.168.50.124"
IP_MAC_PROGRAM_ADDR="http://$MIRROR_SERVER_IP/gentoo/ip_mac_export"
LOCAL_LINUX_SOURCE_SERVER="http://$MIRROR_SERVER_IP/gentoo/gentoo-source/"
LOCAL_PORTAGE_RSYNC_SERVER="rsync://$MIRROR_SERVER_IP/typhon-portage"

# Gentoo specific
TARGET_ARCH="amd64"
STAGE3_BASENAME="stage3-amd64-systemd"

# Directories
TMP_DIR="/tmp/gentoo-stage3-download"
BINDED_INSTALL_DIRECTORY="/tmp/chroot-transfer"
CURRENT_INSTALL_DIRECTORY="$PWD"

# Chroot directories
INSTALL_DIR="$PWD"
CHROOT_TMP_DIRECTORY="/mnt/gentoo/tmp"
CHROOT_OPT_DIRECTORY="/mnt/gentoo/opt"

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

    countdown_timer
    
    # Mount EFI partition
    einfo "Making EFI directory... at /efi"
    mkdir -p "/mnt/gentoo/efi"
    einfo "EFI directory created."
    mount "/dev/${DRIVE}1" "/mnt/gentoo/efi"  # Assuming EFI is the 1st partition
    einfo "Mounted EFI partition."

    countdown_timer

    # Mount /home partition
    mkdir -p "/mnt/gentoo/home"
    mount "/dev/${DRIVE}2" "/mnt/gentoo/home"  # Assuming /home is the 2nd partition
    einfo "Mounted /home partition."

    countdown_timer

    # Mount /var partition
    mkdir -p "/mnt/gentoo/var"
    mount "/dev/${DRIVE}3" "/mnt/gentoo/var"  # Assuming /var is the 3rd partition
    einfo "Mounted /var partition."

    countdown_timer

    # Mount /tmp partition
    mkdir -p "/mnt/gentoo/tmp"
    mount "/dev/${DRIVE}4" "/mnt/gentoo/tmp"  # Assuming /tmp is the 4th partition
    einfo "Mounted /tmp partition."

    countdown_timer

    # Mount /usr partition
    mkdir -p "/mnt/gentoo/usr"
    mount "/dev/${DRIVE}5" "/mnt/gentoo/usr"  # Assuming /usr is the 5th partition
    einfo "Mounted /usr partition."

    countdown_timer

    # Mount /opt partition
    mkdir -p "/mnt/gentoo/opt"
    mount "/dev/${DRIVE}6" "/mnt/gentoo/opt"  # Assuming /opt is the 6th partition
    einfo "Mounted /opt partition."

    countdown_timer

    # Mount /var/log partition
    mkdir -p "/mnt/gentoo/var/log"
    mount "/dev/${DRIVE}7" "/mnt/gentoo/var/log"  # Assuming /var/log is the 7th partition
    einfo "Mounted /var/log partition."

    einfo "ALL Filesystems mounted."

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

function generate_repos_conf_script() {
    einfo "Generating setup_repos_conf.sh script..."
    cat << OUTER_EOF > /mnt/gentoo/tmp/setup_repos_conf.sh
#!/bin/bash
source /tmp/einfo_timer_util.sh

# Create the repos.conf directory
mkdir -p /etc/portage/repos.conf

# Create and configure the gentoo.conf file
cat << INNER_EOF > /etc/portage/repos.conf/gentoo.conf
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = $LOCAL_PORTAGE_RSYNC_SERVER
auto-sync = yes
sync-rsync-verify-jobs = 1
sync-rsync-verify-metamanifest = no
sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
INNER_EOF

einfo "Portage repository configuration complete."
OUTER_EOF
    chmod +x /mnt/gentoo/tmp/setup_repos_conf.sh
}

function generate_make_conf_update_script() {
    einfo "Generating update_make_conf.sh script..."
    cat << EOF > /mnt/gentoo/tmp/update_make_conf.sh
#!/bin/bash
source /tmp/einfo_timer_util.sh

# Update the make.conf file with the GENTOO_MIRRORS setting
if grep -q "^GENTOO_MIRRORS" /etc/portage/make.conf; then
    # Update the existing GENTOO_MIRRORS entry
    sed -i "/^GENTOO_MIRRORS/c\GENTOO_MIRRORS=\"$LOCAL_LINUX_SOURCE_SERVER\"" /etc/portage/make.conf
else
    # Add a new GENTOO_MIRRORS entry
    echo "GENTOO_MIRRORS=\"$LOCAL_LINUX_SOURCE_SERVER\"" >> /etc/portage/make.conf
fi
echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf
echo 'VIDEO_CARDS="nvidia"' >> /etc/portage/make.conf
echo 'USE="X"' >> /etc/portage/make.conf
echo 'LC_MESSAGES=C.utf8' >> /etc/portage/make.conf
einfo "make.conf updated with new GENTOO_MIRRORS setting."
EOF
    chmod +x /mnt/gentoo/tmp/update_make_conf.sh
}

function generate_system_network_setup_script() {
    einfo "Generating system_network_setup.sh script..."
    cat << EOF > /mnt/gentoo/tmp/system_network_setup.sh
#!/bin/bash
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
EOF
    einfo "system_network_setup.sh script generated"
}

function configure_chroot_environment() {

    einfo "Configuring chroot environment..."

    # Create the directories
    mkdir -p "$CHROOT_TMP_DIRECTORY" "$CHROOT_OPT_DIRECTORY"

    # Copy external scripts to the chroot environment
    local scripts=(einfo_timer_util.sh nvidia_driver_install.sh ip_mac_export \
                   setup_user_config.sh build_fstab.sh update_compiler_flags.sh \
                   setup_bootloader.sh update_system_before_install.sh build_kernel.sh \
                   nvidia_kernel_config chroot_commands.sh)

    for script in "${scripts[@]}"; do
        local script_path="$CURRENT_INSTALL_DIRECTORY/utils/$script"
        if [ -f "$script_path" ]; then
            cp "$script_path" "$CHROOT_TMP_DIRECTORY/"
        else
            eerror "Script $script not found in $script_path"
        fi
    done

    # # Copy Source Code to /mnt/gentoo/opt
    # einfo "Copying Source Code to $CHROOT_OPT_DIRECTORY"
    # local source_codes=(nvhpc_2023_2311_Linux_x86_64_cuda_12.3.tar.gz \
    #                     cuda_gdb_src-all-all-12.3.101.tar.gz \
    #                     git-repos.tar.xz \
    #                     hashcat-master.zip john-bleeding-jumbo.zip)

    # for source_code in "${source_codes[@]}"; do
    #     local source_code_path="$CURRENT_INSTALL_DIRECTORY/source_code/$source_code"
    #     if [ -f "$source_code_path" ]; then
    #         cp "$source_code_path" "$CHROOT_OPT_DIRECTORY/"
    #     else
    #         eerror "Source code $source_code not found in $source_code_path"
    #     fi
    # done

    # Generate and copy additional scripts
    generate_repos_conf_script
    generate_make_conf_update_script
    generate_system_network_setup_script

    einfo "All Scripts Generated and/or copied."

    countdown_timer

    # Display all scripts in the chroot environment
    einfo "Listing all scripts in $CHROOT_TMP_DIRECTORY:"
    ls -l "$CHROOT_TMP_DIRECTORY/"

    countdown_timer

    # Make all scripts executable
    einfo "Making all scripts in $CHROOT_TMP_DIRECTORY executable..."
    chmod +x "$CHROOT_TMP_DIRECTORY"/*.sh
    einfo "All scripts in $CHROOT_TMP_DIRECTORY are now executable."
    einfo "Chroot environment configured."

    # Copy DNS Hostings info and mount system devices
    copy_etc_dns_hosts_info
}

function install_in_chroot() {

    einfo "Installing in chroot environment..."

    # Create a script with all commands to be executed in chroot
#     cat << EOF > /mnt/gentoo/tmp/chroot_commands.sh
#         #!/bin/bash

#         set -e  # Exit immediately on error

#         source /etc/profile
#         source /tmp/einfo_timer_util.sh

#         # function einfo() {
#         #     local blue='\e[1;34m'   # Light blue
#         #     local yellow='\e[1;33m' # Yellow
#         #     local red='\e[1;31m'    # Red
#         #     local reset='\e[0m'     # Reset text formatting

#         #     echo -e "${red}----------------------------------------------------------------------------${reset}"
#         #     echo -e "${blue}[${yellow}$(date '+%Y-%m-%d %H:%M:%S')${blue}] $1${reset}"
#         #     echo -e "${red}----------------------------------------------------------------------------${reset}"
#         # }

#         # function countdown_timer() {
#         #     for ((i = 3; i >= 0; i--)); do
#         #         if [ $i -gt 0 ]; then
#         #             echo -ne "\r\033[K\e[31mContinuing in \e[34m$i\e[31m seconds\e[0m"
#         #         else
#         #             echo -e "\r\033[K\e[1;34mContinuing\e[0m"
#         #         fi
#         #         sleep 1
#         #     done
#         # }

#         einfo "Setting up repository configurations..."
#         /tmp/setup_repos_conf.sh

#         einfo "Updating make.conf..."
#         /tmp/update_make_conf.sh

#         einfo "Updating compiler flags..."
#         /tmp/update_compiler_flags.sh

#         einfo "Updating base system before install begins..."
#         /tmp/update_system_before_install.sh

#         einfo "Testing and Displaying IP and MAC export..."
#         /tmp/ip_mac_export

#         einfo "Building kernel..."
#         /tmp/build_kernel.sh

#         einfo "Generating fstab..."
#         /tmp/build_fstab.sh

#         einfo "Installing NVIDIA drivers..."
#         /tmp/nvidia_driver_install.sh

#         einfo "Setting up the bootloader..."
#         /tmp/setup_bootloader.sh

#         einfo "Setting up network and system configurations..."
#         /tmp/system_network_setup.sh

#         einfo "Setting up user configuration..."
#         /tmp/setup_user_config.sh

#         einfo "Chroot installation and configuration complete."
# EOF

    # Make the script executable within the chroot environment
    chmod +x "/mnt/gentoo/tmp/chroot_commands.sh"

    # Function to handle chroot errors
    function handle_chroot_error() {
    read -p "An error occurred. Choose an action: chroot (re-enter), reboot, exit, or unmount-exit (u-exit): " action
    case ${action} in
        chroot )
            einfo "Re-entering chroot environment..."
            chroot /mnt/gentoo /bin/bash
        ;;
        reboot )
            einfo "Rebooting..."
            reboot
        ;;
        exit )
            einfo "Exiting..."
            return 1
        ;;
        u-exit )
            einfo "Unmounting filesystems and exiting..."
            umount -l /mnt/gentoo/dev{/shm,/pts,}
            umount -R /mnt/gentoo
            return 1
        ;;
        * )
            einfo "Invalid option. Recalling Menu"
            handle_chroot_error
            return 1
        ;;
    esac
}

    # Enter chroot and execute the install script
    chroot /mnt/gentoo /bin/bash -c tmp/chroot_commands.sh || {
    eerror "An error occurred during the chroot execution."
    handle_chroot_error
    return 1
}

    einfo "Installation in chroot environment complete."

}

function cleanup_and_reboot() {
    read -p "Do you want to unmount filesystems and cleanup? (y/n) " unmount_answer
    if [[ ${unmount_answer:0:1} =~ [yY] ]]; then
        einfo "Unmounting filesystems..."
        umount -l /mnt/gentoo/dev{/shm,/pts,}
        umount -R /mnt/gentoo
    else
        einfo "Skipping unmounting."
    fi

    read -p "Do you want to reboot now, re-enter chroot, or exit? (reboot/chroot/exit) " action
    case ${action} in
        reboot|Reboot )
            einfo "Rebooting..."
            reboot
        ;;
        chroot|Chroot )
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

    source ./utils/einfo_timer_util.sh

    einfo "HPC Gentoo Automated Linux Installer"
    einfo "POC: La Barge, Alexander"
    einfo "Date: 1 Dec 23"
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
