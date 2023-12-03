#!/bin/bash
source /tmp/install_config.sh
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