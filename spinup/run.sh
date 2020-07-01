#!/bin/bash

# Settings
tool="/usr/bin/time -v"
bin_path=$(pwd)/../snowpack/usr/bin/snowpack
start="1980-01-01T00:00:00"
end="2017-12-31T23:30:00"
thresh=950

# Misc
rm -f to_exec1.lst
rm -f to_exec2.lst
base_dir=$(pwd)/io/
cd ${base_dir}

# Run SNOWPACK in a loop
for dir in */ ; do
	echo "Working on: ${dir}"
	output_path=${base_dir}/${dir}output/
	input_path=${base_dir}/${dir}input/
	depth_tgt_time=9999
		
	# Did the simulation start? Check by seeing if the output directory is empty. If simulation has not started,
	# then add commands to start simulation!
	if [ -z "$(ls -A ${output_path})" ] ; then # Output directory is empty
		echo "	Simulation has not started"
		echo "cd ${input_path}" >> ../to_exec1.lst
		echo "${tool} ${bin_path} -r -c run.ini -e ${end} >> ../output/log.txt 2>&1" >> ../to_exec2.lst
	else # Output directory is not empty
		echo "	Simulation already started"
		pro_file=$(ls -t ${output_path}*pro | head -1)
		depth_tgt_time=$(awk -v d="${start}" -F, 'BEGIN {p=0} {if(/^0500/ && sprintf("%04d-%02d-%02d", substr($NF,7,4), substr($NF,4,2), substr($NF,1,2))==substr(d,1,10)) {p=1}; if(p==1 && /^0501/) {print $NF; exit}}' ${pro_file})
		echo "	Starting depth = ${depth_tgt_time} m"

		# Restart an unfinished simulation
		sno_file=$(ls -t ${output_path}*sno)
		if [ -f "${sno_file}" ]; then # Output directory contains a *sno file
			echo "	Latest simulation finished"
		else # Output directory does not contain a *sno file
			echo "	Latests simulation did not finish" # Restart unfinished simulation
			sno_file=$(ls ${output_path}*sno* | tail -1)
			cp ${sno_file} ${input_path} 
			sno_file=$(ls ${input_path}*sno* | tail -1)
			mv ${sno_file} ${sno_file::(-7)} # Remove 7 numbers from the file exstension
			echo "${tool} ${bin_path} -r -c run.ini -e ${end} >> ../output/log.txt 2>&1" >> ../to_exec2.lst
		fi
	
	fi
	
	# Restart spinup if necessary
	if (( $(echo "${depth_tgt_time} < ${thresh}" | bc -l) )); then # Restart simulation in 1980 if needed
		echo "	Needs spinup"
		# Move latest .sno file into input
		cp ${output_path}*sno ${input_path}
	
		# Change the dates in the .sno file
		sno_file=$(ls -t ${input_path}*sno)
		bash shift_profile.sh ${sno_file} ${start} > ${input_path}/tmp.sno
		sno_file_base_name=$(basename ${sno_file})
		rm ${sno_file}
		mv ${input_path}/tmp.sno ${input_path}${sno_file_base_name} 

		# Launch SNOWPACK
                echo "cd ${input_path}" >> ../to_exec1.lst
                echo "${tool} ${bin_path} -r -c run.ini -e ${end} >> ../output/log.txt 2>&1" >> ../to_exec2.lst
	fi
done

