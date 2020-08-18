Create surface grids by navigating into the  `setup/input_surface_grids/` directory and execute
```
bash create_input_surface_grids.sh
```

Then create atmospheric forcing by first running `setup/input_atmospheric_forcing/write_station_list.ipynb`. This notebook will create a land use file (`dem.lus`) which tells Alpine-3D which initial snow properties file (.sno) to use at each grid cell. Then follow the instructions at `SNOWPACK_WAIS/doc/atmospheric_forcing.md` and `snowpack/Scripts/create_smet_from_netcdf/README.md` to create atmospheric forcing `.smet` files. Note that you will likely need to make a few changes to `snowpack/Scripts/create_smet_from_netcdf/io_files/MERRA-2.ini` including:
* updating the 4 relative paths which point to .nc files
* updating `Virtual parameters` to `Virtual_parameters      =       TA QI VW DW ISWR ILWR PSUM`
* updating `job.sbatch` to the appropriate `slurm` settings. 

Spinup initial snow properties (SNOWPACK .sno files). First, define the number of cpus in job.sbatch `#SBATCH --array=1-N` (where N is equal to the number of lines in to_exec.lst, which is the number of independent MERRA-2 grid cell which need spinup).

```
cd spinup
bash setup.sh
sbatch job.sbatch
bash copy_sno.sh 
```
