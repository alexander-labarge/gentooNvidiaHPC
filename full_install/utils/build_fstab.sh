#!/bin/bash
# kernel_install_fstab.sh

# source /tmp/einfo_timer_util.sh

# # Backup and generate fstab
# einfo "Backing up and generating fstab..."
# cp /etc/fstab /etc/fstab.backup

# # Generate fstab
# emerge --verbose sys-fs/genfstab
# genfstab -U / > /etc/fstab

#!/bin/bash
# build_fstab.sh

source /tmp/einfo_timer_util.sh

# Backup and generate fstab
einfo "Backing up and generating fstab..."
cp /etc/fstab /etc/fstab.backup

# Generating the new fstab entries
einfo "Setting up initial comment in fstab..."
echo "# /etc/fstab: static file system information." | tee /etc/fstab
einfo "Adding blank line..."
echo "#" | tee -a /etc/fstab
einfo "Adding fstab details reference..."
echo "# See fstab(5) for details." | tee -a /etc/fstab
einfo "Adding another blank line..."
echo "#" | tee -a /etc/fstab
einfo "Adding column headers..."
echo "# <file system> <mount point>   <type>  <options>       <dump>  <pass>" | tee -a /etc/fstab

# # Adding partitions to fstab
# einfo "Adding / partition to fstab..."
# echo "UUID=$(blkid -o value -s UUID /dev/${DRIVE}8) / ext4 defaults 0 1" | tee -a /etc/fstab
# einfo "Adding EFI partition to fstab..."
# echo "UUID=$(blkid -o value -s UUID /dev/${DRIVE}1) /boot/efi vfat umask=0077 0 1" | tee -a /etc/fstab
# einfo "Adding /home partition to fstab..."
# echo "UUID=$(blkid -o value -s UUID /dev/${DRIVE}2) /home ext4 defaults 0 2" | tee -a /etc/fstab
# einfo "Adding /var partition to fstab..."
# echo "UUID=$(blkid -o value -s UUID /dev/${DRIVE}3) /var ext4 defaults 0 2" | tee -a /etc/fstab
# einfo "Adding /tmp partition to fstab..."
# echo "UUID=$(blkid -o value -s UUID /dev/${DRIVE}4) /tmp ext4 defaults 0 2" | tee -a /etc/fstab
# einfo "Adding /usr partition to fstab..."
# echo "UUID=$(blkid -o value -s UUID /dev/${DRIVE}5) /usr ext4 defaults 0 2" | tee -a /etc/fstab
# einfo "Adding /opt partition to fstab..."
# echo "UUID=$(blkid -o value -s UUID /dev/${DRIVE}6) /opt ext4 defaults 0 2" | tee -a /etc/fstab
# einfo "Adding /var/log partition to fstab..."
# echo "UUID=$(blkid -o value -s UUID /dev/${DRIVE}7) /var/log ext4 defaults 0 2" | tee -a /etc/fstab

# Generating fstab entries and adding them with einfo messages

# Root partition
ROOT_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID /dev/${DRIVE}8) / ext4 defaults 0 1"
echo "$ROOT_FSTAB_ENTRY" | sudo tee -a /etc/fstab
einfo "Adding / partition to fstab: $ROOT_FSTAB_ENTRY"

countdown_timer

# EFI partition
EFI_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID /dev/${DRIVE}1) /boot/efi vfat umask=0077 0 1"
echo "$EFI_FSTAB_ENTRY" | sudo tee -a /etc/fstab
einfo "Adding EFI partition to fstab: $EFI_FSTAB_ENTRY"

countdown_timer

# /home partition
HOME_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID /dev/${DRIVE}2) /home ext4 defaults 0 2"
echo "$HOME_FSTAB_ENTRY" | sudo tee -a /etc/fstab
einfo "Adding /home partition to fstab: $HOME_FSTAB_ENTRY"

countdown_timer

# /var partition
VAR_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID /dev/${DRIVE}3) /var ext4 defaults 0 2"
echo "$VAR_FSTAB_ENTRY" | sudo tee -a /etc/fstab
einfo "Adding /var partition to fstab: $VAR_FSTAB_ENTRY"

countdown_timer

# /tmp partition
TMP_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID /dev/${DRIVE}4) /tmp ext4 defaults 0 2"
echo "$TMP_FSTAB_ENTRY" | sudo tee -a /etc/fstab
einfo "Adding /tmp partition to fstab: $TMP_FSTAB_ENTRY"

countdown_timer

# /usr partition
USR_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID /dev/${DRIVE}5) /usr ext4 defaults 0 2"
echo "$USR_FSTAB_ENTRY" | sudo tee -a /etc/fstab
einfo "Adding /usr partition to fstab: $USR_FSTAB_ENTRY"

countdown_timer

# /opt partition
OPT_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID /dev/${DRIVE}6) /opt ext4 defaults 0 2"
echo "$OPT_FSTAB_ENTRY" | sudo tee -a /etc/fstab
einfo "Adding /opt partition to fstab: $OPT_FSTAB_ENTRY"

countdown_timer

# /var/log partition
VARLOG_FSTAB_ENTRY="UUID=$(blkid -o value -s UUID /dev/${DRIVE}7) /var/log ext4 defaults 0 2"
echo "$VARLOG_FSTAB_ENTRY" | sudo tee -a /etc/fstab
einfo "Adding /var/log partition to fstab: $VARLOG_FSTAB_ENTRY"

countdown_timer

einfo "Fstab generation complete."
einfo "Contents of /etc/fstab:"
cat /etc/fstab

countdown_timer
