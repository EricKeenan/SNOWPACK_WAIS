#!/bin/bash

#SBATCH --nodes=1                         # Number of requested nodes
#SBATCH --account=ucb164_summit1 
#SBATCH --time=06:00:00                   # Max wall time - 5 hrs for first simulation, 10 hrs for spinup.
#SBATCH --qos=normal                      # Specify testing QOS
#SBATCH --partition=shas                  # Specify Summit haswell nodes
#SBATCH --ntasks=1                       # Number of tasks per job
#SBATCH --array=1-4
##SBATCH --array=1-2

#SBATCH --job-name=SNOWPACK_ensemble         # Job submission name
#SBATCH --output=./io/sbatch_out_files/%x.%j.out     # Output file name with Job ID
#SBATCH --mail-type=ALL
#SBATCH --mail-user=eric.keenan@colorado.edu

# Modules
module purge
ml intel
ml proj

# Retrieve commands from .lst files
command1=$(sed -n ${SLURM_ARRAY_TASK_ID}p to_exec.lst)
command2=$(sed -n ${SLURM_ARRAY_TASK_ID}p to_exec2.lst)

# Execute commands
eval ${command1}
eval ${command2}
