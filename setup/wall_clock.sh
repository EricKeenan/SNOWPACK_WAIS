#!/bin/bash

# Retrieve argument variables
HH=${1}
MM=${2}
SS=${3}
wall_clock_buffer=${4} # minutes

# Remove zero padding, if it exists. 
if [[ ${HH:0:1} == "0" ]] ; then 
	HH=${HH:1:2}
fi
if [[ ${MM:0:1} == "0" ]] ; then 
	MM=${MM:1:2}
fi
if [[ ${SS:0:1} == "0" ]] ; then 
	SS=${SS:1:2}
fi

# Calculate wall clock time in seconds
wall_clock_seconds=$(( ${HH}*3600 + ${MM}*60 + ${SS} ))

# Calculate MAX_RUN_TIME 
max_run_time_seconds=$(( ${wall_clock_seconds} - ${wall_clock_buffer}*60))

# Modify io.ini file
sed -i "s/.*MAX_RUN_TIME.*/MAX_RUN_TIME = ${max_run_time_seconds}/g" io.ini

