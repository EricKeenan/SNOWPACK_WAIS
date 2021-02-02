#!/bin/bash

#SBATCH --nodes=1                         # Number of requested nodes
#SBATCH --account=ucb164_summit1 
#SBATCH --time=24:00:00                   
#SBATCH --qos=normal                      # Specify testing QOS
#SBATCH --partition=shas                  # Specify Summit haswell nodes
#SBATCH --ntasks=1                        # Number of tasks per job
#SBATCH --array=1-64

#SBATCH --job-name=A3D_spinup             # Job submission name
#SBATCH --output=./io/sbatch_out_files/%x.%j.out     # Output file name with Job ID
#SBATCH --mail-type=ALL
#SBATCH --mail-user=eric.keenan@colorado.edu

# Modules
module purge
ml intel
ml proj

# Run SNOWPACK
command1="$(sed -n ${SLURM_ARRAY_TASK_ID}p to_exec.lst)"
${command1}
