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

The subversion certificate authority permissions are messed up on GL
for some reason. <span class="todo">Figure out why this is and make a 
separate post about how to fix this.</span>

```
git clone https://github.com/ESCOMP/CAM ${HOME}/CAM_JUNE22
cd ${HOME}/CAM_JUNE22
git checkout cam_development
yes t | ./manage_externals/checkout_externals

```


## installing missing ESMF dependency

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
make -j8
HERE
```

