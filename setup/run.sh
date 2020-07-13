#!/bin/bash

module purge
ml intel; ml impi; ml proj; ml netcdf

# Are you restarting a previous Alpine-3D simulation? Yes (Y) No (N)
RESTART=$1

REDIRECT_LOGS=N

# Add libraries to path
export LD_LIBRARY_PATH=../snowpack/usr/lib:${LD_LIBRARY_PATH}

# Alpine-3D binary 
EXE=$(pwd)/../snowpack/usr/bin/alpine3d

if [ ! -f ${EXE} ]; then
	EXE=`which alpine3d`
fi

echo "Running with OPENMP"
N_EB=$2
N_SN=$2

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
