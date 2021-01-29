# This script writes an empty .sno file for the begining of a simulation.  

import sys

# Define system arguments
site = sys.argv[1]
lon = sys.argv[2]
lat = sys.argv[3]
altitude = sys.argv[4]
start_time = sys.argv[5]
path = sys.argv[6]

# Define path to write file
fname = path + str(site) + ".sno"

# Open file
f = open(fname,'w')

# Write Lines
f.write("SMET 1.1 ASCII\n")
f.write("[HEADER]\n")
f.write("station_id       = VIR" + site[-1] + "\n")
f.write("station_name     = Virtual_Station_" + site[-1] + "\n")
f.write("longitude        = " + lon + "\n")
f.write("latitude         = " + lat + "\n")
f.write("altitude         = " + altitude+ "\n")
f.write("nodata           = -999\n")
f.write("tz               = 1\n")
f.write("source           = MERRA-2 \n")
f.write("ProfileDate      = " + start_time + "\n")
f.write("HS_Last          = 0.0000\n")
f.write("SlopeAngle       = 0.0\n")
f.write("SlopeAzi         = 0.0\n")
f.write("nSoilLayerData   = 0\n")
f.write("nSnowLayerData   = 0\n")
f.write("SoilAlbedo       = 0.09\n")
f.write("ErosionLevel     = 0\n")
f.write("TimeCountDeltaHS = 0.000000\n")
f.write("BareSoil_z0      = 0.200\n")
f.write("CanopyHeight     = 0.00\n")
f.write("CanopyLeafAreaIndex = 0.00\n")
f.write("CanopyDirectThroughfall = 1.00\n")
f.write("WindScalingFactor = 1.00\n")
f.write("ErosionLevel     = 0\n")
f.write("TimeCountDeltaHS = 0.000000\n")
f.write("fields           = timestamp Layer_Thick  T  Vol_Frac_I  Vol_Frac_W  Vol_Frac_V  Vol_Frac_S Rho_S Conduc_S HeatCapac_S  rg  rb  dd  sp  mk mass_hoar ne CDot metamo\n")
f.write("[DATA]\n")

# Close file 
f.close()

print("Successfully wrote initial .sno file!") 










