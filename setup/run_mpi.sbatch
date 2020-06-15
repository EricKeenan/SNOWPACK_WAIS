#!/bin/bash
#This is the launching script for Alpine3D. Please make sure the user section matches your needs!

#SBATCH --nodes=1                         # Number of requested nodes

#SBATCH --qos=normal                      # Specify testing QOS
#SBATCH --partition=shas                  # Specify Summit haswell nodes
#SBATCH --time=23:59:59                   # Max wall time

##SBATCH --qos=testing                      # Specify testing QOS
##SBATCH --partition=shas-testing           # Specify Summit haswell nodes
##SBATCH --time=00:05:00                    # Max wall time

#SBATCH --ntasks=16                       # Number of tasks per job
#SBATCH --job-name=alpine3d_test1          # Job submission name
#SBATCH --output=alpine3d_test.%j.out     # Output file name with Job ID


# purge all exisitng modules
module purge
module load gcc/6.1.0
module load proj
module load openmpi/2.0.1


# set thread count for openmp
export OMP_NUM_THREADS=16		# This should match number of tasks per node (ntasks/nodes), to run with OpenMP


# set thread count for mpi
mpi_cores=1				# This should match the number of requested nodes




source timespan.inc

PROG_ROOTDIR=../bin/

#should screen messages be redirected to stdouterr.log or printed directly on the screen?
REDIRECT_LOGS=N
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

#TOOL="/usr/bin/time -v "
TOOL="/usr/bin/time -v mpirun -np ${mpi_cores}"
#TOOL="mpirun -np ${mpi_cores}"


A3D_CMD="${TOOL} ${EXE} \
--iofile=./io.ini \
--enable-eb  \
--np-ebalance=${N_EB} \
--np-snowpack=${N_SN} \
--startdate=${BEGIN} --enddate=${END}"

date
if [[ ("${REDIRECT_LOGS}" == "Y") ||  ("${REDIRECT_LOGS}" == "y") ]]; then
	echo "Executing: ${A3D_CMD}" > stdouterr.log 2>&1 $*
	${A3D_CMD} > stdouterr.log 2>&1 $*
else
	echo "Executing: ${A3D_CMD}"
	${A3D_CMD} 2>&1 $*
fi
ret=$?

echo "Done Alpine3D Simulation. Return code=$ret"
date
echo
exit $ret
