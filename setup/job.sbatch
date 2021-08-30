#!/bin/bash
#This is the launching script for Alpine3D. Please make sure the user section matches your needs!

########################## START  USER CONFIGURATION

#SBATCH --ntasks=1                         # Number of requested nodes
#SBATCH --cpus-per-task=4              # Number of threads per node
#SBATCH --account=ucb204_summit1
#SBATCH --time=00:10:00         # Max wall time
#SBATCH --qos=normal                      # Specify testing QOS
#SBATCH --partition=shas-testing                 # Specify Summit haswell nodes

#SBATCH --job-name=alpine3d               # Job submission name
#SBATCH --output=../output/log/%x.%j.out  # Output file name with Job ID
#SBATCH --mail-type=ALL
#SBATCH --mail-user=eric.keenan@colorado.edu

# Wall clock variables
HH=24 # Hours in form HH, e.g. 24 is 24 hours, 01 is 1 hour.
MM=00 # Minutes in form MM, e.g. 59 is 59 minutes, 01 is 1 minute.
SS=00 # Seconds in form SS, e.g. 59 is 59 seconds, 01 is 1 second.
wall_clock_buffer=10 # Minutes. Halt Alpine-3D calculations this many minutes before reaching wall clock time. This allows enough time to write output

# Are you restarting a previous Alpine-3D simulation? Yes (Y) No (N)
restart=N

# Adjust Alpine-3D horizontal spatial resolution. First argument is the target resolution (m)
bash spatial_resolution.sh 1000

# Modify io.ini MAX_RUN_TIME to reflect Slurm wall clock time.
bash wall_clock.sh ${HH} ${MM} ${SS} ${wall_clock_buffer}

# Run Alpine-3D
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
source run.sh ${restart} ${SLURM_NTASKS} ${SLURM_CPUS_PER_TASK}
