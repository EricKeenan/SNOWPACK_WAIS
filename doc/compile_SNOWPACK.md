# Instructions for compiling and installing MeteoIO, SNOWPACK, and Alpine3D. 

1. Clone SNOWPACK github repository
```
git clone https://github.com/snowpack-model/snowpack.git
```
2. Compile MeteoIO
```
ssh scompile
ml intel; ml impi; ml proj; ml cmake; ml netcdf
cd snowpack/Source/meteoio
cp ../../../CMake_Cache/CMakeCache_meteoio.txt CMakeCache.txt
ccmake .
```
Hit [c] for configure

Hit [g] for generate and exit
```
make -j18 install
```
3. Compile SNOWPACK
```
cd ../snowpack/
cp ../../../CMake_Cache/CMakeCache_snowpack.txt CMakeCache.txt
ccmake .
```
Hit [c] for configure

Hit [g] for generate and exit
```
make -j18 install
```
4. Compile Alpine-3D
```
cd ../alpine3d/
cp ../../../CMake_Cache/CMakeCache_alpine3d.txt CMakeCache.txt
ccmake .
```
Hit [c] for configure
If it gives an error because of missing snowpack library, just hit [e] exit and after providing the cmake_install_prefix, it will find it when you hit [c] for configure.

Switch on OpenMP and MPI.

If SNOWPACK has been compiled in the SNOWPACK_CORE option, Alpine3D also needs SNOWPACK_CORE ON (and vice versa). Otherwise it won’t work.
Hit [g] for generate and exit
```
make -j18 install
```
