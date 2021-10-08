---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Building and running the MPAS shallow water core
layout: layouts/post.njk
---

## First steps:

Do the dependency process listed [here](https://open-lab-notebook.glitch.me/posts/installing-mpas)


## Shallow-water specific:

### Clean build system

Try the command `make clean CORE=PREVIOUS_CORE_BUILD` if you have a previous build left on the filesystem

### Make shallow water core:

Try the command `make gfortran CORE=sw PRECISION=single`. Let's see what happens

Seems to need `make gfortran CORE=sw PRECISION=single USE_PIO2=true`.

This command seems to finish correctly. I'm going to search for either the Williamson or Galewsky shallow water test cases.

It appears that in the file `src/core_sw/mpas_sw_test_cases.F` there are several Williamson shallow water test cases.

### Trying to get `sw_test_case_2` working:
This is the "Global  steady state non-linear zonal geostrophic flow" test case.

First I'm going to see if I can find an example shallow water namelist on the mpas repository (I'm not hopeful.)

Turns out a good default namelist is found in `src/core_sw/default_inputs/namelist.sw` and `streams.sw`.




Let's try creating a case directory after the fashion of `core_atmosphere`:

The executable we need is `src/sw_model`.

The correct file to get all of the dependencies set up (assuming you built with shared libraries) is
<details>
<summary>View setup.sh </summary>
<p>
<pre>
<code>

module load gcc/8.2.0
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export MPICH_FC=gfortran
export MPICH_F90=gfortran
export CC=mpicc
export FC=mpif90
export NETCDF=$scratch/dependencies/netcdf_c
export NETCDFF=$scratch/dependencies/netcdf_fortran
export PNETCDF=$scratch/dependencies/pnetcdf
export PIO=$scratch/dependencies/PIO
hdf5=$scratch/dependencies/hdf5
zlib=$scratch/dependencies/zlib
export MPAS_EXTERNAL_INCLUDES="-I$hdf5/include -I$zlib/include"
export MPAS_EXTERNAL_LIBS="-L${hdf5}/lib -L$zlib/lib -lhdf5_hl -lhdf5 -lz -ldl"
export LD_LIBRARY_PATH="$PNETCDF/lib:${NETCDF}/lib:${hdf5}/lib:${hdf5}/lib:${PIO}/lib:${NETCDFF}/lib:${LD_LIBRARY_PATH}"
export FFLAGS="-freal-4-real-8"
</code>
</pre>
</p>
</details>
</details>

where you have to ensure that the shell variables point to the base directory of the 
corresponding dependency installs (i.e. it should have `bin`, `lib`, `include` subdirectories etc)



I created a case directory as follows:
```
mkdir ${MPAS_ROOT}/cases
mkdir ${MPAS_ROOT}/cases/shallow_water_test_case_5


ln -s ${MPAS_ROOT}/MPAS-skamaroc/sw_model ${MPAS_ROOT}/shallow_water/test_case_2/
# This copies the default namelists to our case version
cp ${MPAS_ROOT}/MPAS-skamaroc/src/core_sw/default_inputs/* ${MPAS_ROOT}/shallow_water/test_case_2/

```

where `MPAS_ROOT` is an absolute path to the directory. I have multiple source versions of MPAS in my `$MPAS_ROOT`
directory, hence why I've called one version `MPAS-skamaroc`. Yours is probably just called `MPAS` or something.

For cost's sake, I'll download the grid file from [here](http://www2.mmm.ucar.edu/projects/mpas/atmosphere_meshes/x1.2562.tar.gz)
with a nominal grid resolution of 480km.

From within your case directory, run `wget http://www2.mmm.ucar.edu/projects/mpas/atmosphere_meshes/x1.2562.tar.gz`






  




