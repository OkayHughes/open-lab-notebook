---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Installing E3SM 2.0 on Greatlakes using my jank MPAS dependencies
  parent: E3SM
layout: layouts/post.njk
---

Follow the installation notes from [Joe's excellent README](https://github.com/jhollowed/e3sm_greatlakes_install).


In order to proceed you will need to either 1) follow the installation instructions [here](https://open-lab-notebook.glitch.me/posts/installing-mpas/) or 2) obtain 
the dependencies from me (if you're on greatlakes, check `/nfs/turbo/cjablono2/owhughes/dependencies.tar.gz`)

### Reducing your `~/.cime` config files to a soup-like homogenate.

Change the files in your `~/.cime` directory as follows:

<details>
<summary> ~/.cime/bash.source</summary>
  
```
# from CJ CESM install instructions:
# https://docs.google.com/document/d/1VHEWx3Isxs7csE2tv1bxtTvBkUIVU_LK_jocxjxy1Tw/edit?usp=sharing

module load gcc/8.2.0
module load cmake/3.17.3

  
  
# 
# for E3SM
INPUT_NAME=inputData 
export MY_E3SM_ROOT=${PATH_TO_E3SM}/CLDERA-E3SM
export DIN_LOC_ROOT=${MY_E3SM_ROOT}/${INPUT_NAME}
export MY_E3SM_CASES=${PATH_TO_CASES}
export MY_SLURM_ACCOUNT=cjablono1
export MY_E3SM_SCRATCH=${PATH_TO_E3SM_SCRATCH}


export PATH=$scratch/dependencies/mpich/bin:$PATH
#export MPICH_CC=gcc
#export MPICH_FC=gfortran
#export MPICH_F90=gfortran
#export CC=mpicc
#export FC=mpif90
export NETCDF_C_PATH=$scratch/dependencies/netcdf_c
export NETCDF_F_PATH=$scratch/dependencies/netcdf_fortran
export NETCDF_CPP_PATH=$scratch/dependencies/netcdf_cpp 
export PNETCDF_PATH=$scratch/dependencies/pnetcdf
#export PIO=$scratch/dependencies/PIO
export HDF5_PATH=$scratch/dependencies/hdf5
export ZLIB_PATH=$scratch/dependencies/zlib
export LD_LIBRARY_PATH="${PNETCDF_PATH}/lib:${NETCDF_C_PATH}/lib:${HDF5_PATH}/lib:${NETCDF_CPP_PATH}/lib:${NETCDF_F_PATH}/lib:${LD_LIBRARY_PATH}"
  
```
</details>