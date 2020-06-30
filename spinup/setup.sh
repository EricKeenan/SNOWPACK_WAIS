#!/bin/bash

# Misc tasks
base_dir=$(pwd)
ind0=1
indf=20

# Loop through each MERRA-2 grid cell inside of the MERRA-2 domain
for site in $(seq ${ind0} ${indf}); do 
	echo "Working on site ${site}"
	
	# Make site directory
	cd ${base_dir}
	site_dir=./io/site_${site}
	mkdir -p ${site_dir}
	
	if cd ${site_dir}; then
		# Clear and redifine site directory
 		rm -rf *
	        mkdir -p input
	        mkdir -p output
		
		# Copy input files (.sno, .ini) into input directory. Note that I will have deterimine T_s bottom. 
		cp ../base.ini input/
		cp ../../../input/meteo/A3D_site_${site}.smet input/
	else
		echo cd failed
	fi
done


