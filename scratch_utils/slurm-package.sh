#!/bin/bash

# Define the package to unmask
PACKAGE="sys-cluster/slurm"

# Check if the package.unmask directory exists
if [ ! -d /etc/portage/package.unmask ]; then
    echo "Creating /etc/portage/package.unmask directory..."
    mkdir -p /etc/portage/package.unmask
fi

# Unmask the package
echo "${PACKAGE}" >> /etc/portage/package.unmask/slurm

echo "Package ${PACKAGE} has been unmasked."
