#!/bin/bash

# Define the package and its USE flags
PACKAGE="x11-drivers/nvidia-drivers"
USE_FLAGS="modules strip X persistenced static-libs tools"

# Check if the package.use directory exists
if [ ! -d /etc/portage/package.use ]; then
    echo "Creating /etc/portage/package.use directory..."
    mkdir -p /etc/portage/package.use
fi

# Apply the USE flag changes for the package
echo "${PACKAGE} ${USE_FLAGS}" >> /etc/portage/package.use/custom

echo "USE flag changes for ${PACKAGE} have been applied."
