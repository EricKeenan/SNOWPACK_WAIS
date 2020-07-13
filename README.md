[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/EricKeenan/SNOWPACK_WAIS/master)

# Distributed surface mass balance modeling over the West Antarctic ice sheet using SNOWPACK and Alpine3D

## Instructions 
1. Clone repository into a high performance compute environment, i.e. scratch.
```
git clone https://github.com/EricKeenan/SNOWPACK_WAIS.git
```
2. Compile and install MeteoIO, SNOWPACK, and Alpine-3D by following the directions in `doc/compile_SNOWPACK.md`.

3. Alpine-3D input

If input files (e.g. atmospheric forcing, terrain models, and initial snow properties) already exist:
Copy input into the compute environment by navigating into the `setup` directory and execute
```
bash copy_input.sh
```
Else:
Create input files by following the directions in `doc/input_files.md`

4. Launch Alpine-3D

Configure `slurm` settings and set restart flag to `Y` or `N` in `job.sbatch`. Make sure you are not in a conda environment.
```
conda deactivate
sbatch job.sbatch
```

5. Analyze Alpine-3D simulations by running the notebooks under `analysis/` on your machine of choice or [directly in the cloud](https://mybinder.org/v2/gh/EricKeenan/SNOWPACK_WAIS/master).
