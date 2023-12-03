#!/bin/bash
# setup_user_config.sh

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

# Change Root Password
einfo "Changing root password. Please set a new password."
passwd root

countdown_timer

# Create a new user named skywalker
einfo "Creating new user skywalker..."
useradd -m skywalker -G wheel -s /bin/bash

# Set the password for skywalker
einfo "Set a password for skywalker."
echo "skywalker:password" | chpasswd

# Add the user to all available groups
for group in $(cut -d: -f1 /etc/group); do
    gpasswd -a skywalker $group
done
einfo "Added skywalker to all available groups."

countdown_timer

# Install sudo
einfo "Installing sudo..."
emerge --verbose --autounmask-continue=y app-admin/sudo

# Allow wheel group to use sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
einfo "Sudo configuration complete."

countdown_timer

# Install SSHD
einfo "Installing SSHD..."
emerge --verbose --autounmask-continue=y net-misc/openssh
systemctl enable sshd
# systemctl start sshd
einfo "SSHD installation complete."

countdown_timer

# Configure SSHD for password authentication
einfo "Configuring SSH for password authentication..."
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
einfo "Password authentication enabled for SSH."

# countdown_timer

# # Restart SSH service to apply changes
# einfo "Restarting SSH service..."
# systemctl restart sshd
# einfo "SSH service restarted."
# einfo "Showing SSH Status:"
# systemctl status sshd

countdown_timer

# Generating SSH keys
einfo "Generating SSH keys..."
ssh-keygen -A
einfo "SSH key generation complete."

countdown_timer

# Display SSH keys
einfo "SSH keys:"
cat /etc/ssh/ssh_host_*

countdown_timer

# Display Current IP and MAC Address
einfo "Current IP and MAC Address:"
/tmp/ip_mac_export

countdown_timer

einfo "SSHD configuration complete."