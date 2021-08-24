---
title: Installing HOMME
date: 2021-05-15
tags:
  - posts
layout: layouts/post.njk
---

Ok so after talking to some very talented folks over at the DOE,
I decided that it was time to try to install the Higher Order Method Modeling Environment
(HOMME) on our local cluster computer at U of M.

After some googling I found the following [instructions](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/2735079654/Standalone+HOMME)

I'm going to detail here the process of trying to install this.

### Downloading the code:

The E3SM source seems to be available [here](https://github.com/E3SM-Project/E3SM).
_Note, you should clone this code rather than rely on any releases._
Run `git checkout maint-1.2`

According to the instructions, I'm going to assume that the working directory should be on
`/scratch` somewhere.

It appears that some perl modules are necessary, and that `cime/scripts/Tools/get_case_env` has been renamed to
`cime/scripts/Tools/e3sm_check_env` which shows that some perl modules need to be installed.

None of the perl modules on greatlakes seem useful, so I do the following:

- Use the default `perl` in `/usr/bin`
- Run the following to get perl to install locally `perl -MCPAN -Mlocal::lib -e 'CPAN::install(LWP)'`
- Add the following to your .bashrc `eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"; export PERL5LIB=$HOME/.perl5:$PERL5LIB`
- Then for every module listed in `e3sm_check_env`, run `cpan {MODULENAME}`. You may need to read
  error messages to determine what dependencies are, because perl is terrible.
- The `e3sm_check_env` script has a bug in it: line 54 should read `stat = run_cmd('perl -e "require {};"'.format(module_name))[0] `

  

#### Figuring out which machine file to use:

The suggested file in the tutorial is `mach = $homme/cmake/machineFiles/cori-knl.cmake.`

The default centos configuration seems to be promising, so I'm going to use that as my starting point.

The machine file that worked for me was 
```
# CMake initial cache file for Linux 64bit RHEL7/CENTOS7
# tested with stock gcc/gfortran and packages from EPEL:
#    openmpi-devel 
#    blas-devel
#    lapack-devel
#    netcdf-fortran-devel
#
#
SET (CMAKE_Fortran_COMPILER mpif90 CACHE FILEPATH "")
SET (CMAKE_C_COMPILER mpicc CACHE FILEPATH "")
SET (CMAKE_CXX_COMPILER mpicc CACHE FILEPATH "")
SET (NetCDF_C $ENV{NETCDF_C} CACHE FILEPATH "") 
SET (NetCDF_C_LIBRARY $ENV{NETCDF_C}/lib/libnetcdf.so CACHE FILEPATH "")
SET (NetCDF_C_INCLUDE_DIR $ENV{NETCDF_C}/include CACHE FILEPATH "")
SET (NetCDF_Fortran $ENV{NETCDF_F} CACHE FILEPATH "") 
SET (NetCDF_Fortran_LIBRARY $ENV{NETCDF_F}/lib/libnetcdff.so CACHE FILEPATH "")
SET (NetCDF_Fortran_INCLUDE_DIR $ENV{NETCDF_F}/include CACHE FILEPATH "")
SET (HDF5_C_LIBRARY $ENV{hdf5}/lib/libhdf5.so CACHE FILEPATH "")
SET (HDF5_C_INCLUDE_DIR $ENV{hdf5}/include CACHE FILEPATH "")
SET (HDF5_HL_LIBRARY $ENV{hdf5}/lib/libhdf5_hl.so CACHE FILEPATH "")
SET (HDF5_HL_INCLUDE_DIR $ENV{hdf5}/include CACHE FILEPATH "")
SET (PNETCDF_DIR $ENV{PNETCDF} CACHE FILEPATH "")






SET (WITH_PNETCDF TRUE CACHE FILEPATH "")

# hack until findnetcdf is updated to look for netcdf.mod
#SET (ADD_Fortran_FLAGS "-I/usr/lib64/gfortran/modules" CACHE STRING "")

SET (USE_QUEUING FALSE CACHE BOOL "")
SET (HOMME_FIND_BLASLAPACK TRUE CACHE BOOL "")


```

*However,* this relies on environment variables set in 
```
module load gcc/8.2.0

#module load openmpi/4.0.3
#module load mkl/2021.3.0 
#module load netcdf-c/4.6.2
#module load netcdf-fortran/4.4.5 
#module load python3.6-anaconda/5.2.0 
module load git/2.20.1
export PATH=$scratch/dependencies/mpich/bin:$PATH
export NETCDF_C=$scratch/dependencies/netcdf_c
export NETCDF_F=$scratch/dependencies/netcdf_fortran
export hdf5=$scratch/dependencies/hdf5
export zlib=$scratch/dependencies/zlib
export PNETCDF=$scratch/dependencies/pnetcdf
export FFLAGS="-L${NETCDF_C}/lib -L$hdf5/lib -L$zlib/lib -L$curld/lib -L$PNETCDF/lib"
export CPPFLAGS="-I${NETCDF_C}/include -I$hdf5/include -I$zlib/include -I$curld/include -I$PNETCDF/include"
export LDFLAGS="-L${NETCDF_C}/lib -L$hdf5/lib -L$zlib/lib -L$curld/lib -L$PNETCDF/lib"
export LD_LIBRARY_PATH="$PNETCDF/lib:${NETCDF_C}/lib:${NETCDF_F}/lib:${hdf5}/lib:${zlib}/lib:${LD_LIBRARY_PATH}"


eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib):"

export e3sm="/home/owhughes/HOMME/E3SM"
export homme="$e3sm/components/homme"
export wdir="$scratch/HOMME"
export mach="$homme/cmake/machineFiles/greatlakes.cmake"
```

and unfortunately I haven't kept good notes on the extremely finnicky PERL installation that I had to do to get this code to work. 

#### The jobscript for submitting
I modified the following script for use with slurm on greatlakes. 
Each greatlakes node has 36 "cores", i.e. 18 physical cores with 2 virtual cores after hyperthreading.
I still don't know how to translate between the "PE" numbers in CESM and manual slurm ones (or how to use openmp to its fullest).
This would be worth investigating further, but as it is it appears that this runs in about 2 hours which is shamefully slow for an NE30 run.

```
#!/bin/bash
#
#SBATCH --job-name d16-1-preqx 
#SBATCH --account=cjablono1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1000m 
#SBATCH --time=2:00:00
#
# 25 nodes, 30min sufficient for all 5 runs
# 12 nodes, 10min for r400 an r100
# 

source /home/owhughes/HOMME/E3SM/setup.sh
export OMP_NUM_THREADS=1
export MV2_ENABLE_AFFINITY=0
NCPU=36

# hydrostatic preqx
EXEC=../../../test_execs/theta-l-nlev30/theta-l-nlev30



function run { 
local NCPU=$1
echo "NCPU = $NCPU"
namelist=namelist-$prefix.nl
\cp -f $namelist input.nl
date
mpirun -bind-to=core -np $NCPU $EXEC < input.nl
date

ncl plot-baroclinicwave-init.ncl
ncl plot-lat-lon-TPLSPS.ncl 'var_choice=1'
ncl plot-lat-lon-TPLSPS.ncl 'var_choice=2'
ncl plot-lat-lon-TPLSPS.ncl 'var_choice=3'
\mv -f plot_baroclinicwave_init.pdf  ${prefix}_init.pdf
\mv -f preqx-test16-1latlonT850.pdf  ${prefix}_T850.pdf
\mv -f preqx-test16-1latlonPS.pdf  ${prefix}_PS.pdf
\mv -f preqx-test16-1latlonPRECL.pdf  ${prefix}_PRECL.pdf

\mv -f movies/dcmip2016_test11.nc    movies/${prefix}_dcmip2016_test11.nc
}

prefix=r400    ; run $(($NCPU>384?384:NCPU))

prefix=r100-dry; run $NCPU
prefix=r100-h  ; run $NCPU
prefix=r100    ; run $NCPU

prefix=r50    ; run $NCPU

# high res cases
#prefix=ne120  ; run $NCPU       
#prefix=ne256  ; run $NCPU       
#prefix=ne512  ; run $NCPU       
#prefix=ne1024  ; run $NCPU      

# timings on ANVIL
#ne120  72 nodes, 2h Anvil:  6s
#ne256  72 nodes, 2h Anvil:  55s
#ne512  100 nodes 2h Anvil:  611s (can run on 25 nodes)
#ne1024 100 nodes 2h Anvi:   4642s  (6min init)
#       100 nodes  270 timesteps:  1836s (6min init)
#


```

#### Reconstructing my method of installing Perl dependencies

Since I didn't take good enough notes last time I installed stuff I'm going to redo this.

In order to do a fresh install, remove the HOMME directory from scratch and from ~, remove the ~/perl5 directory as well as the ~/.cpan directory.

