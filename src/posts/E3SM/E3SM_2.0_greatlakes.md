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

  
  
# Change these to suit your installation!
# ====================================================
# for E3SM
INPUT_NAME=inputData 
export MY_E3SM_ROOT=${PATH_TO_E3SM}/CLDERA-E3SM
export DIN_LOC_ROOT=${MY_E3SM_ROOT}/${INPUT_NAME}
export MY_E3SM_CASES=${PATH_TO_CASES}
export MY_SLURM_ACCOUNT=cjablono1
export MY_E3SM_SCRATCH=${PATH_TO_E3SM_SCRATCH}

# for jank dependencies
export DEPENDENCIES="${scratch}/dependencies"
# ====================================================


export PATH=${DEPENDENCIES}/mpich/bin:$PATH
export NETCDF_C_PATH=${DEPENDENCIES}/netcdf_c
export NETCDF_F_PATH=${DEPENDENCIES}/netcdf_fortran
export NETCDF_CPP_PATH=${DEPENDENCIES}/netcdf_cpp 
export PNETCDF_PATH=${DEPENDENCIES}/pnetcdf
export HDF5_PATH=${DEPENDENCIES}/hdf5
export ZLIB_PATH=${DEPENDENCIES}/zlib
export LD_LIBRARY_PATH="${PNETCDF_PATH}/lib:${NETCDF_C_PATH}/lib:${HDF5_PATH}/lib:${NETCDF_CPP_PATH}/lib:${NETCDF_F_PATH}/lib:${LD_LIBRARY_PATH}"

```
</details>


Likewise use the following [~/.cime/config_machines.xml](https://open-lab-notebook.glitch.me/posts/E3SM/config_machines/), [~/.cime/config_compilers.xml](https://open-lab-notebook.glitch.me/posts/E3SM/config_compilers/).
Note: the `config_machines.xml` depends on environment variables set in `~/.cime/bash.source`, so make sure
to run `source ${HOME}/.cime/bash.source` before trying to create cases.

### Creating the case:

Make sure to edit the lines 
```
readonly CODE_ROOT="/home/owhughes/E3SM/CLDERA-E3SM"
readonly CASE_ROOT="/scratch/cjablono_root/cjablono1/owhughes/E3SM/E3SMv2/${CASE_NAME}"
```

Do `cd ~/e3sm_greatlakes_install`

