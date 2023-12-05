#!/bin/bash

# Check for required source files
if [ ! -f /tmp/install_config.sh ] || [ ! -f /tmp/einfo_timer_util.sh ]; then
    echo "Required source files are missing."
    exit 1
fi

source /tmp/install_config.sh
source /tmp/einfo_timer_util.sh
source /etc/profile

# Begin installation and setup
einfo "Installing NVIDIA High Performance Cuda SDK"
countdown_timer

# Informative message about SDK
einfo "The HPC CUDA SDK includes libraries and algorithms optimized for scientific and high-performance computing tasks..."
sleep 5
countdown_timer

# Downloading SDK
einfo "Downloading NVIDIA High Performance Cuda SDK"
wget "$MIRROR_SERVER_EXTRAS_WGET_ADDRESS/nvhpc_2023_2311_Linux_x86_64_cuda_12.3.tar.gz" -O /tmp/nvhpc_2023_2311_Linux_x86_64_cuda_12.3.tar.gz || { eerror "Download failed"; exit 1; }
countdown_timer

einfo "Getting Old School Linux BSD Expect Package to Automate SDK Installation"
emerge --verbose --autounmask-continue=y dev-tcltk/expect || { eerror "Installation failed"; exit 1; }
countdown_timer

# Extracting SDK
einfo "Extracting the SDK"
tar xzf /tmp/nvhpc_2023_2311_Linux_x86_64_cuda_12.3.tar.gz -C /tmp || { eerror "Extraction failed"; exit 1; }
countdown_timer

einfo_purple_bold "NVIDIA HPC CUDA provides Multi-Process Service (MPS), a system that allows GPUs to be shared by multiple jobs. Each job receives a fraction of the GPU’s computing resources.

If you don’t use MPS, the GRES elements defined in the slurm.conf file will be distributed equally across all GPUs on the node.

To specify a fraction of GPU resources available to a specific GRES, set three parameters in the MPS configuration: Name, File, and Count. Note that job requests for MPS-configured resources may only use one GPU per node."
sleep 10

# Installing SDK with expect
einfo "Automating the Installation of the Nvidia HPC CUDA SDK with Expect - (Local Install) to /opt/nvidia/hpc_sdk"
expect -c "
   set timeout -1
   spawn /tmp/nvhpc_2023_2311_Linux_x86_64_cuda_12.3/install
   expect \"Press enter to continue...\"
   send \"\r\"
   expect \"Please choose install option:\"
   send \"1\r\"
   expect \"Installation directory? [/opt/nvidia/hpc_sdk]\"
   send \"\r\"
   expect eof
" || { eerror "Automated installation failed"; exit 1; }

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

einfo "Building OpenMPI with CUDA Support (sys-cluster/openmpi)"
countdown_timer

einfo "During Development, MPI Installation prior to CUDA then set the enviorment variables correctly for inclusion for all other packages to include:"
einfo "1. Slurm"
einfo "2. Hashcat"
einfo "3. John the Ripper"
countdown_timer

einfo_purple_bold "The inclusion of MPI (Message Passing Interface) in a SLURM-managed environment with CUDA-driven GPU nodes significantly enhances the efficiency of parallel computing tasks in high-performance computing (HPC) clusters. While SLURM efficiently allocates resources and schedules jobs, MPI optimizes the communication between nodes in these distributed systems. This synergy is crucial for maximizing performance in complex, parallel, and GPU-intensive workloads. MPI's role is vital in ensuring effective data exchange and process coordination across multiple nodes, ultimately leading to improved scalability, flexibility, and overall performance in GPU-accelerated HPC environments."

einfo_purple_bold "Efficient Communication: MPI provides a robust framework for data exchange between distributed nodes, essential for parallel processing in multi-GPU setups.

Scalability: MPI enables applications to scale across numerous nodes, making it ideal for large-scale HPC tasks.

Standardization: As a widely adopted standard in HPC, MPI offers a uniform approach to inter-node communication, allowing for broader compatibility and optimization of existing applications and libraries.

Enhanced Performance: The combination of MPI's communication efficiency and SLURM's resource management leads to improved performance in parallel computing tasks, especially in complex GPU-accelerated environments."

emerge --verbose --autounmask-continue=y sys-cluster/openmpi || { eerror "Installation failed"; exit 1; }

einfo "Installing NVIDIA High Performance CUDA OpenAPI Integration Addon"
countdown_timer
einfo "GPU-Aware MPI: NVIDIA OpenMPI includes support for GPU-aware MPI communication. This means it is optimized for efficiently transferring data to and from GPUs, which is crucial in HPC environments where GPUs are extensively used for parallel processing tasks."
sleep 10
einfo "NVIDIA OpenMPI is optimized to work with NVIDIA's networking technologies, such as InfiniBand and NVLink, to provide high bandwidth and low latency communication, which are critical for HPC applications."
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
