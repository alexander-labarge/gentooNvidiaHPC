#!/bin/bash
# install_config.sh

# Drive identifier and partition sizes
DRIVE="sda"
EFI_SIZE="1G"
HOME_SIZE="100G"
VAR_SIZE="100G"
TMP_SIZE="100G"
USR_SIZE="100G"
OPT_SIZE="100G"
VAR_LOG_SIZE="100G"

# System configuration
NODE_HOSTNAME="deathstar"
DEFAULT_USER="skywalker"
DEFAULT_USER_PASSWORD="password"
GROUPS_TO_ADD="wheel"

# Time zone and locale configuration
TIMEZONE="America/New_York"
LOCALE="en_US.UTF-8"
COLLATE="C.UTF-8"

# Server and network configuration
MIRROR_SERVER_IP="192.168.50.124"
BASE_ADDRESS="http://$MIRROR_SERVER_IP/gentoo"
MIRROR_SERVER_EXTRAS_WGET_ADDRESS="$BASE_ADDRESS/gentoo-install-extras"
IP_MAC_PROGRAM_ADDR="$BASE_ADDRESS/ip_mac_export"
LOCAL_LINUX_SOURCE_SERVER="$BASE_ADDRESS/gentoo-source/"
LOCAL_PORTAGE_RSYNC_SERVER="rsync://$MIRROR_SERVER_IP/typhon-portage"

# Gentoo specific configuration
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

# ANSI escape codes for red and bold text
RED_BOLD='\033[1;31m'
RESET='\033[0m'
