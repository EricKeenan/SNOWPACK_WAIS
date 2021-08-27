#!/bin/bash

# Load modules
module purge
ml intel; ml impi; ml proj; ml netcdf

# Write stn_lst.lst
bash write_stn_lst.sh

# Are you restarting a previous Alpine-3D simulation? Yes (Y) No (N)
RESTART=$1
num_nodes=$2
num_threads_per_node=$3

# Add libraries to path
export LD_LIBRARY_PATH=../snowpack/usr/lib:${LD_LIBRARY_PATH}

# Alpine-3D binary 
EXE=$(pwd)/../snowpack/usr/bin/alpine3d

# Does the Alpine-3D binary exist. 
if [ ! -f ${EXE} ]; then
	EXE=`which alpine3d`
fi

# Define the number of threads per node available for energy balance and SNOWPACK calculations
N_EB=${num_threads_per_node}
N_SN=${num_threads_per_node}

# If nodes > 1, use MPI, else use OPENMP
if (( ${num_nodes} > 1 )); then 
	echo "Running with MPI"
	TOOL="/usr/bin/time -v mpirun -v -np ${num_nodes}"
else
	echo "Running with OPENMP"
	TOOL="/usr/bin/time -v"
fi

# Restarting an Alpine-3D simulation (Y) or starting from scratch (N)
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
	sed -i "1d" restart_timespan.inc # Remove old start date
	sed -i "1 iBEGIN=\"${line: 19}\"" restart_timespan.inc # Add new start date
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

# Run Alpine-3D
${A3D_CMD} 2>&1 $*
ret=$?

echo "Done Alpine3D Simulation. Return code=$ret"

# Copy output to peta library
d=$(date +%Y-%m-%d)
#mkdir -p /pl/active/nasa_smb/A3D_output/${d}/
#zip -r ../output/A3D_output.zip ../output/*
#cp ../output/A3D_output.zip /pl/active/nasa_smb/A3D_output/${d}/

# Copy output .nc file to dropbox
#dbxcli put ../output/grids/a3d_grids.nc /Public/a3d_grids.nc

date
echo
exit $ret
