#!/bin/bash

# Misc tasks
base_dir=$(pwd)

# Make simulation directories
mkdir -p SP
mkdir -p SP_high
mkdir -p SP_low
mkdir -p SP_warm
mkdir -p SP_cold
mkdir -p SP_more_wind
mkdir -p SP_less_wind

mkdir -p WAIS
mkdir -p WAIS_high
mkdir -p WAIS_low
mkdir -p WAIS_warm
mkdir -p WAIS_cold
mkdir -p WAIS_more_wind
mkdir -p WAIS_less_wind

# Make input output directories
for dir in *[^io]/ ; do
	echo "Working on:  ${dir}"
	if cd ${base_dir}/${dir} ; then
		rm -r *
		mkdir -p input
		mkdir -p output
		cp ../io/base.ini input/
		# Copy input files into input directory
		if [[ ${dir} = SP* ]] ; then # South Pole
			cp ../io/SP.ini input/run.ini
			cp ../io/SP.smet input/
			cp ../io/SP.sno input/	
		else # WAIS
		       cp ../io/WAIS.ini input/run.ini
		       cp ../io/WAIS.smet input/
		       cp ../io/WAIS.sno input/
		fi
		# Modify forcing for ensemble
		if [[ ${dir} == *_high/ ]]; then
			sed -i "s/units_multiplier = 1 1 1 1 1 1 1 1 1.194 1/units_multiplier = 1 1 1 1 1 1 1.2 1 1.194 1/g" input/*.smet	
		elif [[ ${dir} == *_low/ ]]; then
                        sed -i "s/units_multiplier = 1 1 1 1 1 1 1 1 1.194 1/units_multiplier = 1 1 1 1 1 1 0.8 1 1.194 1/g" input/*.smet
		elif [[ ${dir} == *_warm/ ]]; then
                	sed -i "s/units_offset = 0 0 0 0 0 0 0 0 0 16.92/units_offset = 0 3.1 0 0 0 0 0 0 0 16.92/g" input/*.smet
		elif [[ ${dir} == *_cold/ ]]; then
                        sed -i "s/units_offset = 0 0 0 0 0 0 0 0 0 16.92/units_offset = 0 -3.1 0 0 0 0 0 0 0 16.92/g" input/*.smet
                elif [[ ${dir} == *_more_wind/ ]]; then
                        sed -i "s/units_offset = 0 0 0 0 0 0 0 0 0 16.92/units_offset = 0 0 0 2.4 0 0 0 0 0 16.92/g" input/*.smet
                elif [[ ${dir} == *_less_wind/ ]]; then
                        sed -i "s/units_offset = 0 0 0 0 0 0 0 0 0 16.92/units_offset = 0 0 0 -2.4 0 0 0 0 0 16.92/g" input/*.smet
		fi 
	else
		echo cd failed
	fi
done

