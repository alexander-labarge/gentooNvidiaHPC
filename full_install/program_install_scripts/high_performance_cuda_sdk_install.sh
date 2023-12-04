#!/bin/bash

# Check for required source files
if [ ! -f /tmp/install_config.sh ] || [ ! -f /tmp/einfo_timer_util.sh ]; then
    echo "Required source files are missing."
    exit 1
fi

source /tmp/install_config.sh
source /tmp/einfo_timer_util.sh
source /etc/profile

einfo "Installing NVIDIA High Performance Cuda SDK"
countdown_timer

# Informative message about SDK
einfo "The HPC CUDA SDK often includes libraries and algorithms that are specifically optimized for scientific and high-performance computing tasks..."
sleep 5
countdown_timer

# Downloading SDK
einfo "Downloading NVIDIA High Performance Cuda SDK"
wget "$MIRROR_SERVER_EXTRAS_WGET_ADDRESS/nvhpc_2023_2311_Linux_x86_64_cuda_12.3.tar.gz" -O /tmp/nvhpc_2023_2311_Linux_x86_64_cuda_12.3.tar.gz || { eerror "Download failed"; exit 1; }
countdown_timer

# Extracting SDK
einfo "Extracting the SDK"
tar xzf /tmp/nvhpc_2023_2311_Linux_x86_64_cuda_12.3.tar.gz -C /tmp || { eerror "Extraction failed"; exit 1; }
countdown_timer

# Installing SDK
einfo "Installing the Nvidia HPC CUDA SDK (Approx. 5 minutes)"
/tmp/nvhpc_2023_2311_Linux_x86_64_cuda_12.3/install || { eerror "Installation failed"; exit 1; }
countdown_timer

einfo "NVIDIA High Performance CUDA SDK installation complete."
countdown_timer

# Updating environment variables
einfo "Updating the PATH, LD_LIBRARY_PATH, and HPC Compiler variables"
NVARCH=`uname -s`_`uname -m`; export NVARCH
NVCOMPILERS=/opt/nvidia/hpc_sdk; export NVCOMPILERS
export MANPATH="$MANPATH:$NVCOMPILERS/$NVARCH/23.11/compilers/man"
export PATH="$NVCOMPILERS/$NVARCH/23.11/compilers/bin:/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/cuda/12.3/bin:$PATH"
export LD_LIBRARY_PATH="/opt/nvidia/hpc_sdk/Linux_x86_64/23.11/cuda/lib64:$LD_LIBRARY_PATH"

einfo "Environment variables updated:"
einfo "NVARCH=$NVARCH"
einfo "NVCOMPILERS=$NVCOMPILERS"
einfo "MANPATH=$MANPATH"
einfo "PATH=$PATH"
einfo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
sleep 5
countdown_timer

einfo "Installing NVIDIA High Performance CUDA OpenAPI Integration Addon"
countdown_timer
einfo "GPU-Aware MPI: NVIDIA OpenMPI includes support for GPU-aware MPI communication. This means it is optimized for efficiently transferring data to and from GPUs, which is crucial in HPC environments where GPUs are extensively used for parallel processing tasks."
sleep 10
einfor "NVIDIA OpenMPI is optimized to work with NVIDIA's networking technologies, such as InfiniBand and NVLink, to provide high bandwidth and low latency communication, which are critical for HPC applications."
sleep 10
einfo " NVIDIA OpenMPI supports heterogeneous computing environments that include both CPUs and GPUs, allowing for flexible and efficient use of different types of hardware resources within the same application."
sleep 10
einfo "NVIDIA OpenMPI is also optimized to work with NVIDIA's HPC compilers, such as the NVIDIA HPC SDK, to provide high performance and portability for HPC applications."
einfo "Adding Nvidia OpenACC and OpenMP compiler flags to environment variables"
export PATH=$NVCOMPILERS/$NVARCH/23.11/comm_libs/mpi/bin:$PATH
export MANPATH=$MANPATH:$NVCOMPILERS/$NVARCH/23.11/comm_libs/mpi/man
export LD_LIBRARY_PATH=$NVCOMPILERS/$NVARCH/23.11/comm_libs/mpi/lib:$LD_LIBRARY_PATH
export PATH=$NVCOMPILERS/$NVARCH/23.11/comm_libs/nccl/bin:$PATH
einfo "Environment variables updated:"
einfo "PATH=$PATH"
einfo "MANPATH=$MANPATH"
einfo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
sleep 5
countdown_timer

# Testing NVIDIA HPC CUDA SDK presence
einfo "Testing Presence of NVIDIA HPC CUDA SDK on Path"
nvcc --version || { eerror "NVIDIA HPC CUDA SDK (nvcc) not found on path"; exit 1; }
einfo "NVIDIA HPC CUDA SDK test complete"
countdown_timer
