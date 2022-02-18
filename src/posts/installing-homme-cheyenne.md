---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Installing HOMME on Cheyenne
  parent: Installing Dycores
layout: layouts/post.njk
---



### 1: Download the code

The E3SM source seems to be available [here](https://github.com/E3SM-Project/E3SM).
_Note, you should clone this code rather than rely on any releases._
Run `git checkout maint-1.2`.
<span class="todo">
  Notes: apparently if you don't run this checkout, the cime directory is empty. So don't worry if this happens! (it took me like half an hour to figure this out when I was first doing this install.)
</span>

Clone this into `${HOME}/E3SM/E3SM` (I use this extra directory because I have several versions
of E3SM to keep track of, e.g. `${HOME}/E3SM/E3SM_v2`).

### 2: Create script which configures shell env and source it
Cheyenne-specific configuration is done in a file that I placed at `${HOME}/.e3sm.source.bash`


<details>
<summary>.e3sm.source.bash</summary>
  
```
  
module load intel/18.0.5  openmpi/4.0.5
module load netcdf-mpi/4.7.4
module load pnetcdf/1.12.2

eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib):"
export PERL5LIB=$HOME/perl5:$PERL5LIB


export E3SM="$HOME/E3SM/E3SM"
export HOMME="$E3SM/components/homme"
export wdir="/glade/scratch/${USER}/HOMME"
export mach="${HOMME}/cmake/machineFiles/cheyenne.cmake"
  
```
</details>

At this point run `source ${HOME}/.e3sm.source.bash` this the perl command will cause an error message. 
This is actually fine for the moment.

### 3: Install `perl` dependencies



The file `cime/scripts/Tools/e3sm_check_env`  shows that some perl modules need to be installed.

- Run `cpanm LWP`
- The `${E3SM}/cime/scripts/Tools/e3sm_check_env` script has a bug in it: line 54 should read `stat = run_cmd('perl -e "require {};"'.format(module_name))[0] `
<span class="todo"> You might not need to fix this if you're using newer code than I am.</span>
- Then for every module listed in `e3sm_check_env`, run `cpan {MODULENAME}`, e.g. `cpan XML::LibXML && cpan XML::SAX && cpan XML::SAX::Exception && cpan Switch`



  

### 4: Creating a Cheyenne-specific machine file

<span class="todo">This is very brittle to the compilers and netcdf verions that
you use</span>



My machine file is located at `mach = $homme/cmake/machineFiles/cheyenne.cmake`

<details>
<summary>cheyenne.cmake</summary>

```
SET (CMAKE_Fortran_COMPILER mpif90 CACHE FILEPATH "")
SET (CMAKE_C_COMPILER mpicc CACHE FILEPATH "")
SET (CMAKE_CXX_COMPILER mpicc CACHE FILEPATH "")
SET (NetCDF_C /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/ CACHE FILEPATH "") 
SET (NetCDF_C_LIBRARY /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/lib/libnetcdf.so CACHE FILEPATH "")
SET (NetCDF_C_INCLUDE_DIR /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/include CACHE FILEPATH "")
SET (NetCDF_Fortran /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/ CACHE FILEPATH "") 
SET (NetCDF_Fortran_LIBRARY /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/lib/libnetcdff.so CACHE FILEPATH "")
SET (NetCDF_Fortran_INCLUDE_DIR /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/include CACHE FILEPATH "")
SET (HDF5_C_LIBRARY /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/lib/libhdf5.so CACHE FILEPATH "")
SET (HDF5_C_INCLUDE_DIR /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/include CACHE FILEPATH "")
SET (HDF5_HL_LIBRARY /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/lib/libhdf5_hl.so CACHE FILEPATH "")
SET (HDF5_HL_INCLUDE_DIR /glade/u/apps/ch/opt/netcdf-mpi/4.7.4/openmpi/4.0.5/intel/18.0.5/include CACHE FILEPATH "")
SET (PNETCDF_DIR /glade/u/apps/ch/opt/pnetcdf/1.12.2/openmpi/4.0.5/intel/18.0.5/ CACHE FILEPATH "")






SET (WITH_PNETCDF TRUE CACHE FILEPATH "")

# hack until findnetcdf is updated to look for netcdf.mod
#SET (ADD_Fortran_FLAGS "-I/usr/lib64/gfortran/modules" CACHE STRING "")

SET (USE_QUEUING FALSE CACHE BOOL "")
SET (HOMME_FIND_BLASLAPACK TRUE CACHE BOOL "")


```  

</details>

### 5: Check point
This is probably extraneous for people are fluent in 

* Ensure that your `.e3sm.source.bash` points to the correct directories.
* Ensure that you have checked if there is an error in `${E3SM}/cime/scripts/Tools/e3sm_check_env`, then it is fixed
* Ensure that the necessary `perl` dependencies are installed.
* Ensure that the file `${HOMME}/cmake/machineFiles/cheyenne.cmake` exists and points to
folders that are consistent with the modules loaded in `.e3sm.source.bash`.
* Ensure that you have run `source ${HOME}/.e3sm.source.bash` in your current shell.


### 6: Build the dycore executables
* Run `cd $wdir`
* Run `cmake -C  $mach $HOMME`
* In order to check whether compilation works, run `make -j8 all`

### 7: Prepare the acid test

- Run `cd $wdir/dcmip_tests/dcmip2012_test2.0_steady_state_with_orography/preqx/`
- Run `make install` (note, this generates default namelist files and such)

### 8: The jobscript for submitting
This is a modified submission script that seems to work on cheyenne. Add it to the folder that you just `cd`'d into.

<details>
<summary>
preqx.jobscript-cheyenne.sh
</summary>

```
#!/bin/bash
#
#PBS -N PREQX_ACID_TEST
#PBS -A YOUR_PROJECT
#PBS -l walltime=01:00:00
#PBS -q regular
#PBS -M YOUR_USERNAME
#PBS -l select=1:ncpus=36:mpiprocs=36
#
# 25 nodes, 30min sufficient for all 5 runs
# 12 nodes, 10min for r400 an r100
# 

source ${HOME}/.e3sm.source.bash
export OMP_NUM_THREADS=2
export MV2_ENABLE_AFFINITY=0
NCPU=36
EXEC=../../../test_execs/preqx-nlev30-interp/preqx-nlev30-interp



function run { 
local NCPU=$1
echo "NCPU = $NCPU"
namelist=namelist-$prefix.nl
\cp -f $namelist input.nl
date
mpirun -np ${NCPU} $EXEC < input.nl
date

}

prefix=default    ; run $(($NCPU>384?384:NCPU))


```
  
</details>

### 9: Running the model and viewing output
  
- As usual, run `qsub preqx.jobscript-cheyenne.sh`
- Use your NetCDF viewer of choice to view `$wdir/dcmip_tests/dcmip2012_test2.0_steady_state_with_orography/preqx/movies/dcmip2012_test2_01.nc`
  

  
  


