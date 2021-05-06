Atmospheric forcing (.smet files) can be created from climate model netCDF files using the [worflow](https://github.com/snowpack-model/snowpack/tree/master/Scripts/create_smet_from_netcdf) located in `snowpack/Scripts/create_smet_from_netcdf/`

Note that because Alpine-3D operates on South Polar Sterographic grid (EPSG 3031) we must rotate the wind direction vectors. This can be accomplished by adding the following to the configuration file (e.g. `MERRA-2.ini`).
```
[INPUT]
Virtual_parameters      =       TA QI VW DW ISWR ILWR PSUM
VW::create              =       Windcomponents

[FILTERS]
DW::filter1             = TRANSFORMWINDVECTOR
DW::arg1::COORDPARAM    = 3031          ; Antarctic Polar Stereographic
```

Wind speed and direction can be calculated using the `WindNinja` model and an [existing workflow](https://github.com/EricKeenan/antarctic-windninja). Once the appropriate downscalling is performed, the data can be provided to `Alpine-3D` with the following
```bash
cd /scratch/summit/erke2265/SNOWPACK_WAIS/input/surface-grids
mkdir wind
cd wind
cp /scratch/summit/erke2265/antarctic-windninja/PIG/processed_output/*.asc .

mkdir VW_DRIFT
cd VW_DRIFT
for f in ../*.asc
do 
	name=$(basename -s .asc ${f})
	ln -s ${f} ${name}_DRIFT.asc
done
```
