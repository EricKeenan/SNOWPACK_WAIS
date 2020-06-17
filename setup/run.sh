#!/bin/bash
#This is the launching script for Alpine3D. Please make sure the user section matches your needs!

# Exit any conda environment
conda deactivate 

# Modules
module purge
ml intel; ml impi; ml proj; ml netcdf

# Get simulation start and stop times
source timespan.inc

# Alpine-3D binary directory
PROG_ROOTDIR=/scratch/summit/erke2265/SNOWPACK_WAIS/snowpack/usr/bin/

# Clear and create new output directory
rm -rf ../output/grids
rm -rf ../output/snofiles
rm -rf ../outout/meteo

mkdir -p ../output/grids
mkdir -p ../output/snofiles
mkdir -p ../output/meteo


########################## END OF USER CONFIGURATION
export LD_LIBRARY_PATH=/scratch/summit/erke2265/SNOWPACK_WAIS/snowpack/usr/lib:${LD_LIBRARY_PATH}

EXE="${PROG_ROOTDIR}/alpine3d"


N_EB=1
N_SN=1


TOOL="/usr/bin/time -v"

${TOOL} ${EXE} \
--iofile=./io.ini \
--enable-eb  \
--startdate=${BEGIN} --enddate=${END}

