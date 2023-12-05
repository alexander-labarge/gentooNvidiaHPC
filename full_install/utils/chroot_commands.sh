#!/bin/bash

# Source necessary profiles and utilities
source /etc/profile
source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

einfo "Starting script execution in chroot environment..."

# Execute various setup and configuration scripts
chmod +x /tmp/*.sh
/tmp/setup_repos_conf.sh
/tmp/update_make_conf.sh
/tmp/update_compiler_flags.sh
/tmp/update_system_before_install.sh
/tmp/ip_mac_export
/tmp/build_kernel.sh
/tmp/build_fstab.sh
/tmp/nvidia_driver_install.sh
/tmp/setup_bootloader.sh
/tmp/system_network_setup.sh
/tmp/setup_user_config.sh
/tmp/program_installs/high_performance_cuda_sdk_install.sh
# /tmp/program_installs/hashcat_install.sh
# /tmp/program_installs/munge_install.sh
# /tmp/program_installs/slurm_install.sh
# /tmp/program_installs/mpi_install.sh


einfo "Cleaning up Dependencies..."
# Clean up dependencies
emerge --verbose --depclean
einfo "Dependencies cleaned up."

einfo "Chroot installation and configuration complete."

# End of script
