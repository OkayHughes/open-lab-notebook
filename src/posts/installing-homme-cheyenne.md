---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Installing HOMME on Cheyenne
  parent: Installing Dycores
layout: layouts/post.njk
---


This is 

### 1: Download the code:

The E3SM source seems to be available [here](https://github.com/E3SM-Project/E3SM).
_Note, you should clone this code rather than rely on any releases._
Run `git checkout maint-1.2`.
<span class="todo">
  Note for Peter: I haven't tried this on the newer code you sent me yet.
  It's on my todo list.
</span>

Clone this into `${HOME}/E3SM/E3SM` (I use this extra directory because I have several versions
of E3SM to keep track of, e.g. `${HOME}/E3SM/E3SM_v2`).

### 2: Create script which configures shell env and source it.
Cheyenne-specific configuration is done in a file that I placed at `${HOME}/.e3sm.source.bash`


<details>
<summary>.e3sm.source.bash</summary>
  
```
  
module load intel/18.0.5  openmpi/4.0.5
module load netcdf-mpi/4.7.4
module load pnetcdf/1.12.2

export PATH="/usr/local/packages/mpich/bin:$PATH"
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

### Install `perl` dependencies.



The file `cime/scripts/Tools/e3sm_check_env`  shows that some perl modules need to be installed.

- Run the following to get perl to install locally `cpan App::cpanminus`
- Run `cpanm LWP`
- The `${E3SM}/cime/scripts/Tools/e3sm_check_env` script has a bug in it: line 54 should read `stat = run_cmd('perl -e "require {};"'.format(module_name))[0] `
<span class="todo"> You might not need to fix this if you're using newer code than I am.</span>
- Then for every module listed in `e3sm_check_env`, run `cpanm {MODULENAME}`, e.g. `cmapm XML::LibXML && cpanm XML::SAX && XML::SAX::Exception && Switch`



  

### Creating a Cheyenne-specific machine file

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
SET (PNETCDF_DIR /glade/u/apps/ch/opt/pnetcdf/1.12.2/openmpi/4.0.5/gnu/8.3.0/ CACHE FILEPATH "")






SET (WITH_PNETCDF TRUE CACHE FILEPATH "")

# hack until findnetcdf is updated to look for netcdf.mod
#SET (ADD_Fortran_FLAGS "-I/usr/lib64/gfortran/modules" CACHE STRING "")

SET (USE_QUEUING FALSE CACHE BOOL "")
SET (HOMME_FIND_BLASLAPACK TRUE CACHE BOOL "")


```  

</details>

### Check point:
This is probably extraneous for people are fluent in 

* Ensure that your `.e3sm.source.bash` points to the correct directories.
* Ensure that you have checked if there is an error in `${E3SM}/cime/scripts/Tools/e3sm_check_env`, then it is fixed
* Ensure that the necessary `perl` dependencies are installed.
* Ensure that the file `${HOMME}/cmake/machineFiles/cheyenne.cmake` exists and points to
folders that are consistent with the modules loaded in `.e3sm.source.bash`.
* Ensure that you have run `source ${HOME}/.e3sm.source.bash` in your current shell.


### Build the 
* Run `cd $wdir`
* Run `cmake -C  $mach $homme`
* In order to check whether compilation works, run `make -j8 all`

#### Running BW wave with precip:
* Run the following:
```
make install
cd dcmip_tests/dcmip2016_test1_baroclinic_wave/
make install
cd theta-l
make install
```

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
#SBATCH --time=0:60:00
#
# 25 nodes, 30min sufficient for all 5 runs
# 12 nodes, 10min for r400 an r100
# 

source /home/owhughes/HOMME/E3SM/setup.sh
export OMP_NUM_THREADS=1
#export OMP_STACKSIZE=16M     #  Cori has 96GB per node. had to lower to 8M on 3K nodes
export MV2_ENABLE_AFFINITY=0
NCPU=36
#if [ -n "$PBS_ENVIRONMENT" ]; then
#  NCPU=$PBS_NNODES
#  [ "$PBS_ENVIRONMENT" = "PBS_BATCH" ] && cd $PBS_O_WORKDIR 
#  NCPU=$PBS_NNODES
#  let NCPU/=$OMP_NUM_THREADS
#fi
#if [ -n "$SLURM_NNODES" ]; then
#    NCPU=$SLURM_NNODES
#    let NCPU*=16
#    let NCPU/=$OMP_NUM_THREADS
#fi
#let PPN=36/$OMP_NUM_THREADS

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

Copy the above into a file located at `$wdir/dcmip_tests/dcmip2016_test1_baroclinic_wave/theta-l/jobscript-greatlakes.sh`


#### Reconstructing my method of installing Perl dependencies

Since I didn't take good enough notes last time I installed stuff I'm going to redo this.

In order to do a fresh install, remove the HOMME directory from scratch and from ~, remove the ~/perl5 directory as well as the ~/.cpan directory.

