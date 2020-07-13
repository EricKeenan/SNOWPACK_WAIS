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

# purge all exisitng modules and add ones required
module purge
ml intel; ml impi; ml proj; ml netcdf

# set thread count for openmp
export OMP_NUM_THREADS=$(nproc)

# Alpine-3D binary directory
PROG_ROOTDIR=$(pwd)/../snowpack/usr/bin/

#should screen messages be redirected to stdouterr.log or printed directly on the screen?
REDIRECT_LOGS=N
RESTART=Y

########################## END OF USER CONFIGURATION
export LD_LIBRARY_PATH=../snowpack/usr/lib:${LD_LIBRARY_PATH}

# Alpine-3D binary 
EXE="${PROG_ROOTDIR}/alpine3d"

if [ ! -f ${EXE} ]; then
	EXE=`which alpine3d`
fi

echo "Running with OPENMP"
N_EB=$OMP_NUM_THREADS
N_SN=$OMP_NUM_THREADS

TOOL="/usr/bin/time -v"

if [[ ("${RESTART}" == "N") ]]; then
	# Get simulation start and stop times
	source timespan.inc

	A3D_CMD="${TOOL} ${EXE} \
	--iofile=./io.ini \
	--enable-eb  \
	--np-ebalance=${N_EB} \
	--np-snowpack=${N_SN} \
	--startdate=${BEGIN} --enddate=${END}"
	
	# Clear and create new output directory
	rm -rf ../output/grids
	rm -rf ../output/snofiles
	rm -rf ../output/meteo

	mkdir -p ../output/grids
	mkdir -p ../output/snofiles
	mkdir -p ../output/meteo

else
	# Get simulation start and stop times
	cp timespan.inc restart_timespan.inc
	file=$(ls ../output/snofiles/1_1_* | head -1)
	line=$(sed -n '/ProfileDate/p' $file)
	sed -i "s/1980-01-01T01:00/${line: 19}/g" restart_timespan.inc
	source restart_timespan.inc

        A3D_CMD="${TOOL} ${EXE} \
        --iofile=./restart.ini \
        --enable-eb  \
	--restart \
        --np-ebalance=${N_EB} \
        --np-snowpack=${N_SN} \
        --startdate=${BEGIN} --enddate=${END}"
fi

date
if [[ ("${REDIRECT_LOGS}" == "Y") ||  ("${REDIRECT_LOGS}" == "y") ]]; then
	${A3D_CMD} > ../output/log/stdouterr.log 2>&1 $*
else
	${A3D_CMD} 2>&1 $*
fi
ret=$?

echo "Done Alpine3D Simulation. Return code=$ret"

# Copy output to peta library
d=$(date +%Y-%m-%d)
mkdir -p /pl/active/nasa_smb/A3D_output/${d}/
zip -r ../output/A3D_output.zip ../output/*
cp ../output/A3D_output.zip /pl/active/nasa_smb/A3D_output/${d}/

# Copy output .nc file to dropbox
dbxcli put ../output/grids/a3d_grids.nc /Public/a3d_grids.nc

date
echo
exit $ret
