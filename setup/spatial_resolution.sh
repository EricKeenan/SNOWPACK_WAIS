#!/bin/bash

ml intel
ml gdal

# Script to adjust surface grids so that Alpine-3D can  run at an arbitrary spatial resolution. 

# Define target and default spatial resolution in meters. 
tgt_res=$1
src_grid_path=../input/surface-grids/
default_res=$(gdalinfo ${src_grid_path}/TSG.asc | fgrep "Pixel Size" | tr '(,' ' ' | awk '{printf "%d", $4}')

# Create a new input directory if tgt_res does not equal default_res
if (( ${tgt_res} == ${default_res} )); then
	echo "Target resolution equals default resolution, no action required." 
	
	# Modify .ini file to read from default surface grids directory
	sed -i 's/modified_surface_grids/surface-grids/' io.ini
else
	echo "Target resolution does not equal default resolution, creating new surface-grids."
	
	# Create new directory
	new_grids_dir=../input/modified_surface_grids
	rm -rf ${new_grids_dir}
	mkdir -p ${new_grids_dir}

	# Modify .ini file to read from ${new_grids_dir}
	sed -i 's/surface-grids/modified_surface_grids/' io.ini	

	# Create new grids with tgt_res
	gdal_translate -of AAIGrid -tr ${tgt_res} ${tgt_res} ${src_grid_path}/dem.asc ${new_grids_dir}/dem.asc
	gdal_translate -of AAIGrid -tr ${tgt_res} ${tgt_res} ${src_grid_path}/dem.lus ${new_grids_dir}/dem.lus
	gdal_translate -of AAIGrid -tr ${tgt_res} ${tgt_res} ${src_grid_path}/TSG.asc ${new_grids_dir}/TSG.asc

	# Copy original POI file
	cp ${src_grid_path}/dem.poi ${new_grids_dir}/dem.poi 
	# The copied POI file currently causes A3D to crash because it contains points outside of the domain. So far now I remove all data points from the file.
	sed -i '/^-/d' ${new_grids_dir}/dem.poi 

	# Modify the resolution of the wind direction and speed files
	# Loop over each file in the directory
 	FILES="../input/surface-grids/wind/198001*.asc"
 	new_winds_grid_dir=${new_grids_dir}/wind/
 	rm -rf ${new_winds_grid_dir}
 	mkdir ${new_winds_grid_dir}
	rm -r ${new_winds_grid_dir}/VW_DRIFT
	mkdir -p ${new_winds_grid_dir}/VW_DRIFT	

 	for f in $FILES
 	do
 		filename=$(basename ${f})
        	gdal_translate -of AAIGrid -tr ${tgt_res} ${tgt_res} ${f} ${new_winds_grid_dir}/${filename}

		if [ "${filename: -6}" == "VW.asc" ]
		then
			cp ${new_winds_grid_dir}/${filename} ${new_winds_grid_dir}/VW_DRIFT/${filename}
			mv ${new_winds_grid_dir}/VW_DRIFT/${filename} ${new_winds_grid_dir}/VW_DRIFT/${filename:: 15}VW_DRIFT.asc
		fi
    done
fi
