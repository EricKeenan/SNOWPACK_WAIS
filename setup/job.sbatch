#!/bin/bash
#This is the launching script for Alpine3D. Please make sure the user section matches your needs!

########################## START  USER CONFIGURATION

#SBATCH --nodes=1                         # Number of requested nodes
#SBATCH --ntasks-per-node=24               # Number of threads per node
#SBATCH --account=ucb164_summit1
#SBATCH --time=24:00:00                   # Max wall time
#SBATCH --qos=normal                      # Specify testing QOS
#SBATCH --partition=shas                  # Specify Summit haswell nodes

#SBATCH --job-name=alpine3d               # Job submission name
#SBATCH --output=../output/log/%x.%j.out  # Output file name with Job ID
#SBATCH --mail-type=ALL
#SBATCH --mail-user=eric.keenan@colorado.edu

# Are you restarting a previous Alpine-3D simulation? Yes (Y) No (N)
restart=N

# Determine the number of nodes 
num_nodes=${SLURM_JOB_NUM_NODES}

# Determine the number of threads per node
num_threads_per_node=${SLURM_JOB_CPUS_PER_NODE%%(*}

# Run Alpine-3D
bash run.sh ${restart} ${num_nodes} ${num_threads_per_node}
