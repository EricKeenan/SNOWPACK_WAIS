# Distributed surface mass balance modeling over the West Antarctic ice sheet using SNOWPACK and Alpine3D

## Minimum working example 
1. Clone repository into a high performance compute environment, i.e. scratch. 
```
git clone https://github.com/EricKeenan/SNOWPACK_WAIS.git
```
2. Compile and install MeteoIO, SNOWPACK, and Alpine-3D by following the directions in `doc/compile_SNOWPACK.md`
3. Navigate into the setup directory and copy input files (e.g. atmospheric forcing, terrain models, etc) from permenant storage environment into compute environment
```
bash copy_input.sh
```
4. Launch Alpine-3D mimumum working example using `openmp`. Make sure you are not in a conda environment.
```
conda deactivate
sbatch run_openmp.sbatch
```
