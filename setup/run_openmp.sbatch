#!/bin/bash
#This is the launching script for Alpine3D. Please make sure the user section matches your needs!

########################## START  USER CONFIGURATION

#SBATCH --nodes=1                         # Number of requested nodes

##SBATCH --time=23:59:59                   # Max wall time
#SBATCH --time=00:15:00                   # Max wall time

##SBATCH --qos=normal                      # Specify testing QOS
#SBATCH --qos=testing                      # Specify testing QOS

##SBATCH --partition=shas                  # Specify Summit haswell nodes
#SBATCH --partition=shas-testing                  # Specify Summit haswell nodes

#SBATCH --ntasks=16                       # Number of tasks per job

#SBATCH --job-name=alpine3d_test          # Job submission name
#SBATCH --output=alpine3d_test.%j.out     # Output file name with Job ID

#SBATCH --mail-type=ALL
#SBATCH --mail-user=eric.keenan@colorado.edu

# purge all exisitng modules
module purge
ml intel; ml impi; ml proj; ml netcdf

# set thread count for openmp
export OMP_NUM_THREADS=4

source timespan.inc

PROG_ROOTDIR=../bin/

# Make output directory
mkdir -p /scratch/summit/erke2265/a3d_test_4core/output/grids
mkdir -p /scratch/summit/erke2265/a3d_test_4core/output/snowfiles

# Clear output directories 
rm /scratch/summit/erke2265/a3d_test_4core/output/grids/* 
rm /scratch/summit/erke2265/a3d_test_4core/output/snowfiles/*

# Make binaries directory, clear, and copy
mkdir -p /projects/erke2265/test_4core/bin/
rm ../bin/*
cp /projects/erke2265/src/AIS_snowpack/usr/bin/* ../bin/
cp /projects/erke2265/src/AIS_snowpack/usr/lib/* ../bin/

#should screen messages be redirected to stdouterr.log or printed directly on the screen?
REDIRECT_LOGS=Y

########################## END OF USER CONFIGURATION

export DYLD_FALLBACK_LIBRARY_PATH=${PROG_ROOTDIR}:${DYLD_FALLBACK_LIBRARY_PATH}	#for osX
export LD_LIBRARY_PATH=${PROG_ROOTDIR}:${LD_LIBRARY_PATH}	#for Linux
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
	${A3D_CMD} > stdouterr.log 2>&1 $*
else
	${A3D_CMD} 2>&1 $*
fi
ret=$?

echo "Done Alpine3D Simulation. Return code=$ret"
date
echo
exit $ret
