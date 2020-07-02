# Distributed surface mass balance modeling over the West Antarctic ice sheet using SNOWPACK and Alpine3D

## Minimum working example 
1. Clone repository into a high performance compute environment, i.e. scratch. 
```
git clone https://github.com/EricKeenan/SNOWPACK_WAIS.git
```
2. Compile and install MeteoIO, SNOWPACK, and Alpine-3D by following the directions in `doc/compile_SNOWPACK.md`
3. Alpine3D input

If input files (e.g. atmospheric forcing, terrain models, etc) already exist:
Copy input into the compute environment by navigating into the `setup` directory and execute
```
bash copy_input.sh
```
Else:
Create input surface grids by navigating into the  `setup/input_surface_grids/` directory and execute
```
bash create_input_surface_grids.sh
```
4. Launch Alpine-3D mimumum working example using `openmp`. Make sure you are not in a conda environment.
```
conda deactivate
sbatch run_openmp.sbatch
```
