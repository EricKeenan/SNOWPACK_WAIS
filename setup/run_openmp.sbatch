#!/bin/bash
#This is the launching script for Alpine3D. Please make sure the user section matches your needs!

########################## START  USER CONFIGURATION

#SBATCH --nodes=1                         # Number of requested nodes
#SBATCH --account=ucb164_summit1
#SBATCH --time=01:30:00                   # Max wall time
#SBATCH --qos=normal                      # Specify testing QOS
#SBATCH --partition=shas                  # Specify Summit haswell nodes
#SBATCH --ntasks=8                       # Number of tasks per job

#SBATCH --job-name=alpine3d_test          # Job submission name
#SBATCH --output=../output/log/%x.%j.out     # Output file name with Job ID
#SBATCH --mail-type=ALL
#SBATCH --mail-user=eric.keenan@colorado.edu

# Are you restarting a previous Alpine-3D simulation? Yes (Y) No (N)
restart=N

# Determine the number of CPUs available
num_cpu=$(nproc)

# Run Alpine-3D
bash run.sh ${restart} ${num_cpu}
