#!/bin/bash

source /projects/erke2265/miniconda/etc/profile.d/conda.sh
conda activate alpine3d

# Misc tasks
base_dir=$(pwd)
ind0=1
indf=$(ls ${base_dir}/../input/meteo/*.smet | wc -l)
start_time="1980-01-01T00:00:00"

# Loop through each MERRA-2 grid cell inside of the MERRA-2 domain
for site in $(seq ${ind0} ${indf}); do 
	echo "Working on site ${site}"
	
	# Make site directory
	cd ${base_dir}
	site_dir=./io/site_${site}
	mkdir -p ${site_dir}
	
	# Define site variables	
	site_name=A3D_site_${site}
	smet_path=../input/meteo/A3D_site_${site}.smet
	lat_str="$(sed -n '/latitude/p' ${smet_path})"
	lon_str="$(sed -n '/longitude/p' ${smet_path})"
	altitude_str="$(sed -n '/altitude/p' ${smet_path})"

	lon=$(echo ${lon_str} | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
	lat=$(echo ${lat_str} | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
	altitude=$(echo ${altitude_str} | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')

	if cd ${site_dir}; then
		# Clear and redifine site directory
 		rm -rf *
	        mkdir -p input
	        mkdir -p output
		
		# Copy input files into input directory.
		cp ../base.ini input/
		cp ../../../input/meteo/A3D_site_${site}.smet input/
		python3 ../../write_sno.py ${site_name} ${lon} ${lat} ${altitude} ${start_time} ./input/ 
		python3 ../../write_ini.py ${site_name} ${lat} ${lon} ./input/
	else
		echo cd failed
	fi
done


