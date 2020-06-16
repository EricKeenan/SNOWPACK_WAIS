#!/bin/bash
#This is the launching script for Alpine3D. Please make sure the user section matches your needs!

########################## START  USER CONFIGURATION

#SBATCH --nodes=1                         # Number of requested nodes
#SBATCH --account=ucb164_summit1
##SBATCH --time=23:59:59                   # Max wall time
#SBATCH --time=01:00:00                   # Max wall time
##SBATCH --qos=normal                      # Specify testing QOS
##SBATCH --qos=testing                      # Specify testing QOS
#SBATCH --partition=shas                  # Specify Summit haswell nodes
##SBATCH --partition=shas-testing                  # Specify Summit haswell nodes
#SBATCH --ntasks=16                       # Number of tasks per job

#SBATCH --job-name=alpine3d_test          # Job submission name
#SBATCH --output=../output/log/%x.%j.out     # Output file name with Job ID
#SBATCH --mail-type=ALL
#SBATCH --mail-user=eric.keenan@colorado.edu

# purge all exisitng modules
module purge
ml gcc; ml impi; ml proj; ml netcdf

# set thread count for openmp
export OMP_NUM_THREADS=4

source timespan.inc

PROG_ROOTDIR=$(pwd)/../usr/bin/

# Clear and create new output directory
rm -rf ../output/grids
rm -rf ../output/snofiles
rm -rf ../outout/meteo

mkdir -p ../output/grids
mkdir -p ../output/snofiles
mkdir -p ../output/meteo

#should screen messages be redirected to stdouterr.log or printed directly on the screen?
REDIRECT_LOGS=N

########################## END OF USER CONFIGURATION
export LD_LIBRARY_PATH=../usr/lib:${LD_LIBRARY_PATH}
#export LD_LIBRARY_PATH=../snowpack/Source/alpine3d/lib/:${LD_LIBRARY_PATH}
#export LD_LIBRARY_PATH=${PROG_ROOTDIR}:${LD_LIBRARY_PATH}	#for Linux
EXE="${PROG_ROOTDIR}/alpine3d"

if [ ! -f ${EXE} ]; then
	EXE=`which alpine3d`
fi

N_EB=1
N_SN=1

echo "Running with OPENMP"
N_EB=$OMP_NUM_THREADS
N_SN=$OMP_NUM_THREADS

TOOL="/usr/bin/time -v"

A3D_CMD="${TOOL} ${EXE} \
--iofile=./io.ini \
--enable-eb  \
--np-ebalance=${N_EB} \
--np-snowpack=${N_SN} \
--startdate=${BEGIN} --enddate=${END}"

date
if [[ ("${REDIRECT_LOGS}" == "Y") ||  ("${REDIRECT_LOGS}" == "y") ]]; then
	${A3D_CMD} > ../output/log/stdouterr.log 2>&1 $*
else
	${A3D_CMD} 2>&1 $*
fi
ret=$?

echo "Done Alpine3D Simulation. Return code=$ret"
date
echo
exit $ret
