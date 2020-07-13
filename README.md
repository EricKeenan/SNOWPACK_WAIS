[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/EricKeenan/SNOWPACK_WAIS/master)

# Distributed surface mass balance modeling over the West Antarctic ice sheet using SNOWPACK and Alpine3D

## Instructions 
1. Clone repository into a high performance compute environment, i.e. scratch. 
```
git clone https://github.com/EricKeenan/SNOWPACK_WAIS.git
```
2. Compile and install MeteoIO, SNOWPACK, and Alpine-3D by following the directions in `doc/compile_SNOWPACK.md`
3. Alpine3D input

If input files (e.g. atmospheric forcing, terrain models, and initial snow properties) already exist:
Copy input into the compute environment by navigating into the `setup` directory and execute
```
bash copy_input.sh
```
Else:
Create input surface grids by navigating into the  `setup/input_surface_grids/` directory and execute
```
bash create_input_surface_grids.sh
```

Then create atmospheric forcing by first running `setup/input_atmospheric_forcing/write_station_list.ipynb`. Then follow the instructions at `snowpack/Scripts/create_smet_from_netcdf/README.md` to create atmospheric forcing `.smet` files. Note that you will likely need to make a few changes to `snowpack/Scripts/create_smet_from_netcdf/io_files/MERRA-2.ini` including:
* updating the 4 relative paths which point to .nc files
* updating `Virtual parameters` to `Virtual_parameters      =       TA QI VW DW ISWR ILWR PSUM`
* updating `job.sbatch` to the appropriate `slurm` settings. 

Spinup initial snow properties (SNOWPACK .sno files). First, define the number of cpus in job.sbatch `#SBATCH --array=1-N` (where N is equal to the number of lines in to_exec.lst, which is the number of independent MERRA-2 grid cell which need spinup.)

```
cd spinup
bash setup.sh
sbatch job.sbatch
bash copy_sno.sh 
```

4. Set restart flag to `Y` or `N` in `job.sbatch`. Launch Alpine-3D mimumum working example. Make sure you are not in a conda environment.
```
conda deactivate
sbatch job.sbatch
```
