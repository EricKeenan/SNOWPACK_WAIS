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
