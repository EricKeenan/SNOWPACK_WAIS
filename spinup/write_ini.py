import sys
import xarray as xr

# Define system arguments
site = sys.argv[1]
lat = sys.argv[2]
lon = sys.argv[3]
path = sys.argv[4]

# Define path to write file
fname = path + "run.ini"

# Open file
f = open(fname,'w')

# Calculate boundary condition
T_s = xr.open_dataset("/pl/active/nasa_smb/MERRA2/yearly_files/TS_mean_1980_2017.nc")
T_s = T_s["TS"].sel(lon=float(lon), lat=float(lat), method="nearest")
T_s = float(T_s.values)

# Write Lines
f.write("[GENERAL]\n")
f.write("IMPORT_BEFORE = ./base.ini\n")
f.write("BUFF_CHUNK_SIZE        =       370\n")
f.write("BUFF_BEFORE    =       1.5\n")
f.write("\n")

f.write("[INPUT]\n")
f.write("METEOPATH      =      ./\n")
f.write("STATION1       =     " +  str(site) + ".smet"  + "\n")
f.write("SNOWPATH       =      ./\n")
f.write("SNOWFILE1      =     " +  str(site) + ".sno"  + "\n")
f.write("VW_DRIFT::COPY =      VW\n")
f.write("\n")

f.write("[OUTPUT]\n")
f.write("METEOPATH      =       ../output/\n")
f.write("\n")

f.write("[SNOWPACKADVANCED]\n")
f.write("VARIANT        =       POLAR\n")
f.write("SNOW_EROSION   =       REDEPOSIT\n") 
f.write("MAX_SIMULATED_HS = 10 \n")
f.write("REDUCE_N_ELEMENTS = 2 \n")
f.write("SNOW_EROSION_FETCH_LENGTH = 10 \n")
f.write("\n")

f.write("[GENERATORS]\n")
f.write("TSG::cst::value    =    " + str(T_s))

# Close file 
f.close()

print("Successfully Wrote .ini file!")
