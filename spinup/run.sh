#!/bin/bash

# Settings
tool="/usr/bin/time -v"
bin_path=$(pwd)/../snowpack/usr/bin/snowpack
export LD_LIBRARY_PATH=$(pwd)/../snowpack/usr/lib/:${LD_LIBRARY_PATH}
start="1980-01-01T00:00:00"
end="2019-12-31T23:30:00"
thresh=10000
site=$1
max_start=$(date +%s -d "+23 hours +30 minutes")

# Misc
base_dir=$(pwd)/io/
cd ${base_dir}${site}/input/
shopt -s extglob

# Run SNOWPACK
echo Working on ${site}
depth_tgt_time=0

# Did the simulation start? Check by seeing if the output directory is empty. If simulation has not started, then add commands to start simulation!
if [ -z "$(ls -A ../output/)" ] ; then # Output directory is empty
	echo "  Simulation has not started"
	${tool} ${bin_path} -r -c run.ini -e ${end} >> ../output/log.txt 2>&1
	pro_file=$(ls -t ../output/*.pro | head -1)
        depth_tgt_time=$(awk -v d="${end}" -F, 'BEGIN {p=0} {if(/^0500/ && sprintf("%04d-%02d-%02d", substr($NF,7,4), substr($NF,4,2), substr($NF,1,2))==substr(d,1,10)) {p=1}; if(p==1 && /^0501/) {print $NF; exit}}' ${pro_file})

else # Output directory is not empty
	echo "  Simulation already started"
	pro_file=$(ls -t ../output/*.pro | head -1)
	depth_tgt_time=$(awk -v d="${end}" -F, 'BEGIN {p=0} {if(/^0500/ && sprintf("%04d-%02d-%02d", substr($NF,7,4), substr($NF,4,2), substr($NF,1,2))==substr(d,1,10)) {p=1}; if(p==1 && /^0501/) {print $NF; exit}}' ${pro_file})
	echo "	Starting depth = ${depth_tgt_time} m"

	# Restart an unfinished simulation
	sno_file=$(ls -t ../output/*.sno)
	if [ -f "${sno_file}" ]; then # Output directory contains a *sno file
		echo "	Latest simulation finished"
	else # Output directory does not contain a *sno file
		echo "	Latest simulation did not finish" # Restart unfinished simulation
		sno_file=$(ls ../output/*sno* | tail -1)
		rm *.sno
		cp ${sno_file} A3D_${site}.sno
		${tool} ${bin_path} -r -c run.ini -e ${end} >> ../output/log.txt 2>&1
		depth_tgt_time=$(awk -v d="${end}" -F, 'BEGIN {p=0} {if(/^0500/ && sprintf("%04d-%02d-%02d", substr($NF,7,4), substr($NF,4,2), substr($NF,1,2))==substr(d,1,10)) {p=1}; if(p==1 && /^0501/) {print $NF; exit}}' ${pro_file})
	fi
fi
	
# Restart spinup if necessary
while [ "$(bc <<< "$depth_tgt_time < $thresh")" == "1"  ]; do
	# Break out of while loop if there is not enough time to save .sno output
	if [ $(date '+%s') -lt "${max_start}" ]; then
		echo "  Needs spinup"
		echo $depth_tgt_time
	else
		echo "	Ran out of spinup wall clock time"
		break
	fi

	# Move latest .sno file into input
	rm *.sno
	cp ../output/*sno A3D_${site}.sno
	pushd ../output
	rm -v !("log.txt")
	popd
	
	# Change the dates in the .sno file
	sno_file=$(ls -t *sno)
	bash ../../../shift_profile.sh ${sno_file} ${start} > tmp.sno
	sno_file_base_name=$(basename ${sno_file})
	rm ${sno_file}
	mv tmp.sno ${sno_file_base_name} 

	# Launch SNOWPACK
	${tool} ${bin_path} -r -c run.ini -e ${end} >> ../output/log.txt 2>&1

	# Update depth_target_time
	pro_file=$(ls -t ../output/*.pro | head -1)
        depth_tgt_time=$(awk -v d="${end}" -F, 'BEGIN {p=0} {if(/^0500/ && sprintf("%04d-%02d-%02d", substr($NF,7,4), substr($NF,4,2), substr($NF,1,2))==substr(d,1,10)) {p=1}; if(p==1 && /^0501/) {print $NF; exit}}' ${pro_file})	
done

# Prepare sno file for Alpine-3D
cp ../output/*sno ..
mv ../*sno ../tmp.sno
bash ../../../shift_profile.sh ../tmp.sno ${start} > ../thwaites_${site: 5}.sno 
rm ../tmp.sno

