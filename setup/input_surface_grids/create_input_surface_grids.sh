#!/bin/bash

# This script will create surface grids required as input for Alpine-3D including:
# 	- Digital elevation models (DEM)
# 	- Point of interest files (.poi)
# 	- Land use files (.lus)

# Purge all modules and add only required ones
module purge
ml intel; ml proj; ml gdal

# Coordinates of upper left and lower right corners of new DEM in EPSG:3031
# Use get_DEM_coords.ipynb to determine what exactly they need to be.
# They need to be exact! Otherwise sub-pixel shift occurs, which is bad!
ulx=-1557000
uly=13000
lrx=-1359000
lry=-124000

# IO file paths
src_dem_path=/pl/active/nasa_smb/Data/IS2_cycle_1_2_3_DEM_noFilter.tif
tgt_dem_path=./dem.asc
src_poi_path=/pl/active/nasa_smb/Data/waiscoresatmhelmslater-v2-subset_pig_v1.csv
tgt_poi_path=./dem.poi
tgt_lus_path=./dem.lus

# Create DEM
gdal_translate -of AAIGrid -a_nodata -9999 -projwin ${ulx} ${uly} ${lrx} ${lry} ${src_dem_path} ${tgt_dem_path}
echo "Done trimming DEM"

# Create point of interest file
echo "SMET 1.1 ASCII" > ${tgt_poi_path}
echo "[HEADER]" >> ${tgt_poi_path}
echo "station_id      = my_pts" >> ${tgt_poi_path}
echo "comment = This file contains Points Of Interests (POI) for full snow stratigraphy outputs" >> ${tgt_poi_path}
echo "epsg    = 3031" >> ${tgt_poi_path}
echo "nodata  = -9999" >> ${tgt_poi_path}
echo "fields = easting northing altitude" >> ${tgt_poi_path}
echo "[DATA]" >> ${tgt_poi_path}
# Write only one point 
#echo "-1540866.3823673 -41575.556604363 0" >> ${tgt_poi_path}
# Write at atmospheric forcing grid cells
for file in ../../input/meteo/*; do
	X=$(awk '/^easting/' ${file} | sed 's/[^-0-9.]*//g')
	Y=$(awk '/^northing/' ${file} | sed 's/[^-0-9.]*//g')
	altitude=$(awk '/^altitude/' ${file} | sed 's/[^0-9.]*//g')
	# if ulx < X < lrx and lry < Y < uly
	if (( $(echo "$X > $ulx" | bc -l) )); then
		if (( $(echo "$X < $lrx" | bc -l) )); then
			if (( $(echo "$Y > $lry" | bc -l) )); then
				if (( $(echo "$Y < $uly" | bc -l) )); then
					echo "	The grid cell is in the domain"
					echo "${X} ${Y} ${altitude}" >> ${tgt_poi_path}
				fi
			fi
		fi
	fi
done

# Write to points determined by file (note the source EPSG looks strange. Are you sure that is correct?)
#awk -F, '(NR>1) {print $15, $1}' ${src_poi_path} | gdaltransform -s_srs EPSG:4296 -t_srs EPSG:3031 >> ${tgt_poi_path}
echo "Done making POI file"

# Create land use file
awk '{if(NR>6) {for(i=1; i<=NF; i++) {if(i>1) {printf " "}; printf "1"}; printf "\n"} else {print}}' ${tgt_dem_path} > ${tgt_lus_path}
echo "Done making LUS file"
