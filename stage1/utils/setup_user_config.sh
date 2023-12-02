#!/bin/bash
# setup_user_config.sh

source /tmp/einfo_timer_util.sh

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
emerge app-admin/sudo

# Allow wheel group to use sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
einfo "Sudo configuration complete."

countdown_timer

# Install SSHD
einfo "Installing SSHD..."
emerge net-misc/openssh
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

# # Add Public Key to Authorized Keys
# einfo "Please enter your public key:"
# read SSH_PUBLIC_KEY
# mkdir -p /home/$DEFAULT_USER/.ssh
# echo $SSH_PUBLIC_KEY > /home/$DEFAULT_USER/.ssh/authorized_keys
# chown -R $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER/.ssh
# chmod 700 /home/$DEFAULT_USER/.ssh
# chmod 600 /home/$DEFAULT_USER/.ssh/authorized_keys

# countdown_timer

einfo "Public Key Authentication Summary:"
einfo "1. You provided a public SSH key, which is now stored in the server's authorized_keys file."
einfo "2. This key enables secure, passwordless SSH access to the server."
einfo "3. To access the server, your SSH client must use the corresponding private key."
einfo "4. The server verifies your identity by checking if your client's private key matches the stored public key."
einfo "5. Keep your private key secure: it's your identity for SSH access."
einfo "6. If the private key is compromised or lost, remove the associated public key from the server immediately."
einfo "7. Access the server using SSH with your private key, without the need for a password."

einfo "SSHD configuration complete."