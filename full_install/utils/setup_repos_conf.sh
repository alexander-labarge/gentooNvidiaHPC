#!/bin/bash
source /tmp/install_config.sh
source /tmp/einfo_timer_util.sh

# Create the repos.conf directory
mkdir -p /etc/portage/repos.conf

# Create and configure the gentoo.conf file
cat << EOF > /etc/portage/repos.conf/gentoo.conf
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
EOF

einfo "Portage repository configuration complete."