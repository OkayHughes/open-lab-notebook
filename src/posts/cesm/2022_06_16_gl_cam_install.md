---
date: 2021-09-01
tags:
  - posts
  - cesm
eleventyNavigation:
  key: 2022/06/14 CAM devel install on UM GreatLakes system
  parent: Community Earth System Model lifehacks
layout: layouts/post.njk
---

## Step 1: Subversion is messed up on greatlakes

The subversion certificate authority permissions are too strict for silent
`checkout_externals` to run successfully.

```
git clone https://github.com/ESCOMP/CAM ${HOME}/CAM_JUNE22
cd ${HOME}/CAM_JUNE22
git checkout cam_development
yes t | ./manage_externals/checkout_externals

```


## installing missing ESMF dependency
The fastest way to do this is to run
```
rsync --progress -r /home/owhughes/esmf ${HOME}/esmf
```

But if you want to do it from source, then use the following:

```
mkdir ${HOME}/esmf \
  && cd ${HOME}/esmf

wget https://github.com/esmf-org/esmf/archive/refs/tags/v8.3.0.tar.gz \
  && tar -xf v8.3.0.tar.gz \
  && cd esmf-8.3.0

cat << HERE > build.sh
module load intel/18.0.5
module load openmpi/3.1.4
export ESMF_DIR=`pwd`
export ESMF_LIB=`pwd`
export ESMF_CXX=mpicxx
export ESMF_COMM=openmpi
export ESMF_COMPILER=intel
export ESMF_F90=mpif90
make -j4
HERE

bash build.sh
```

This will take a while to run (> 5 minutes?).

## Copying machine files
Run 
```
cp -rv  /home/owhughes/.cime_CAM_june ${HOME}/.cime
```

This copies over machine configuration files that are specific to
our Greatlakes machine.


## creating a case

Run the following code:

```
mkdir -p ${HOME}/make_cases \
  && cd ${HOME}/make_cases \
  && wget https://open-lab-notebook.glitch.me/public/scripts/case_creation_script_june.sh \
  && mkdir -p ${HOME}/cesm_cases \
  && bash case_creation_script_june.sh
```

If this runs correctly, it will create a JW06 (one of the test cases)
case directory located at `${HOME}/cesm_cases/CAM_JUNE22/test_cases/CAM_JUNE22.ne30_ne30_mg17.FADIAB.36.test_cases.jw06`


In order to build and run this case do
```
cd ${HOME}/cesm_cases/CAM_JUNE22/test_cases/CAM_JUNE22.ne30_ne30_mg17.FADIAB.36.test_cases.jw06 \
  && (source bash.source && bash xml_config_helper.sh) \
  && (source bash.source && ./case.build) \
  && (source bash.source && ./case.submit)
```


