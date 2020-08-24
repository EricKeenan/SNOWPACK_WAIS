#!/bin/bash

# Create meteo file list
output_file=stn_lst.lst
echo "[Input]" > ${output_file}
count=0
for input_file in ../input/meteo/*smet
do
        let count=${count}+1
        name=$(basename ${input_file})
        echo STATION${count}=${name%%.*} >> ${output_file}
done
