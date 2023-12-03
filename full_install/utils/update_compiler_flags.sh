#!/bin/bash
# update_compiler_flags.sh

source /tmp/einfo_timer_util.sh
source /tmp/install_config.sh

einfo "Syncing to Decryption Team Portage tree..."

countdown_timer

emerge --sync

countdown_timer

einfo "Updating compiler flags for NVIDIA and CPU..."

countdown_timer

# Define the package and its USE flags
PACKAGE="x11-drivers/nvidia-drivers"
USE_FLAGS="modules strip X persistenced static-libs tools"


einfo "Applying Customized USE flag changes for ${PACKAGE}..."

# Create package.use directory if it does not exist
[ -d /etc/portage/package.use ] || mkdir -p /etc/portage/package.use

# Apply the USE flag changes for the package
echo "${PACKAGE} ${USE_FLAGS}" >> /etc/portage/package.use/custom
einfo "USE flag changes for ${PACKAGE} have been applied."

countdown_timer

# Install cpuid2cpuflags and apply CPU-specific USE flags
einfo "Installing cpuid2cpuflags and applying CPU-specific USE flags..."
emerge --verbose --autounmask-continue=y app-portage/cpuid2cpuflags

countdown_timer
einfo "Creating CPU-specific USE flags file..."
# Create package.use directory if it does not exist
[ -d /etc/portage/package.use ] || mkdir -p /etc/portage/package.use
CPU_FLAGS="$(cpuid2cpuflags)"
echo "*/* ${CPU_FLAGS}" > /etc/portage/package.use/00cpu-flags
einfo "CPU-specific USE flags have been applied."
einfo "CPU flags added were: ${CPU_FLAGS}"

countdown_timer

# Define additional necessary USE flag changes

einfo "Apply Kernel Specific Initramfs Use Flags"
USE_CHANGES=(
    "sys-kernel/installkernel-gentoo grub"
)

# Apply additional USE flag changes
for change in "${USE_CHANGES[@]}"; do
    echo "${change}" >> /etc/portage/package.use/custom
done

einfo "Additional USE flag changes have been applied."

countdown_timer

einfo "Updating USE flags for all packages..."
# Backup and update make.conf with optimized CPU flags
cp /etc/portage/make.conf /etc/portage/make.conf.bak2
OPTIMIZED_FLAGS="$(gcc -v -E -x c /dev/null -o /dev/null -march=native 2>&1 | grep /cc1 | sed -n 's/.*-march=\([a-z]*\)/-march=\1/p' | sed 's/-dumpbase null//')"

if [ -z "${OPTIMIZED_FLAGS}" ]; then
    einfo "Failed to extract optimized CPU flags"
    exit 1
fi

# Remove trailing space in COMMON_FLAGS
COMMON_FLAGS=$(echo "${COMMON_FLAGS}" | sed 's/ *$//')

# Update COMMON_FLAGS in make.conf
sed -i "/^COMMON_FLAGS/c\COMMON_FLAGS=\"-O2 -pipe ${OPTIMIZED_FLAGS}\"" /etc/portage/make.conf
sed -i 's/COMMON_FLAGS="\(.*\)"/COMMON_FLAGS="\1"/;s/  */ /g' /etc/portage/make.conf

# Assign MAKEOPTS automatically
NUM_CORES=$(nproc)
MAKEOPTS_VALUE=$((NUM_CORES + 1))
echo "MAKEOPTS=\"-j${MAKEOPTS_VALUE}\"" >> /etc/portage/make.conf

einfo "make.conf has been updated successfully."

countdown_timer

einfo "Flags added were: ${OPTIMIZED_FLAGS}"

countdown_timer

einfo "MAKEOPTS Compiler Available CPU Cores have been set to: -j${MAKEOPTS_VALUE}"

countdown_timer

einfo "Make.conf File Contents Now:"
cat /etc/portage/make.conf
countdown_timer

einfo "Finished updating USE flags for all packages and system specific options"

countdown_timer
