#!/bin/bash

cp -r /pl/active/nasa_smb/A3D_WAIS_Input/* ../input/

# Rename smet file (e.g. from VIR10.smet to A3D_site_10.smet)
cd ../input/meteo/
FILES="*"
for f in $FILES
do
	mv $f A3D_site_${f: 3}
done

