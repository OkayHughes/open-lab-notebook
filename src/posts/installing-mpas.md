---
title: Installing MPAS on Greatlakes
date: 2021-08-30
tags:
  - posts
eleventyNavigation:
  key: Installing MPAS on GreatLakes
  parent: Installing
layout: layouts/post.njk
---

 
## Introductory notes:
### Installation was done without shared libraries.
This was done in order to rectify linker errors that occured during MPAS compilation. There may be a combination of compile flags and environment variables that does not have errors, but I have not tested it.
### The gcc compiler was used for the final install.
 It is likely that the compilation would succeed when an intel compiler was used, however a installation was never performed with any version of the intel compiler.
### Compilation of dependencies must be performed in a directory on `/scratch`
The network volume that hosts your `$HOME` directory uses an NFS filesystem with caching enabled. This prevents installation of the `mpich` dependency. `/scratch` is a GPFS (general purpose file system), and thus works. 
I have not tested whether install files can be moved to $HOME after compilation, or even whether it is stable to write to non-`/scratch` directories. Initial tests writing small files to `$HOME` indicate that it works, but it may fail silently for larger files or with more nodes.

## Dependencies: their versions and interdependence

### 0. Create a directory on `/scratch`
0. Ensure by running `echo $PATH` or examining your `.bashrc` that your bash has no modules loaded (e.g. due to CESM build). In particular, *Ensure that you have not loaded any version of OpenMPI*
1. Define a variable in your `.bashrc` that points to your scratch directory, and call it ${scratch}. This variable is used throughout the provided scripts.
2. create a subdirectory to hold your dependencies and their source files. The following list shows the directory structure that I use:

* `${scratch}/dependencies`: contains install directories for dependencies
	* `${scratch}/dependencies/src`: contains all source files for dependencies

### 1. gcc
1. Run `module load gcc/8.2.0`. 
This will load the executables `gfortran` and `gcc`.

**Checks**: 

1. run `which gfortran` and ensure that it points to the one for the gcc 8.2.0 package, as opposed to `/usr/bin`
2. run `which gcc` to do the same check

### 2. mpich 3.3.2

1. While in the directory `$scratch/dependencies/src` run `wget http://www.mpich.org/static/downloads/3.3.2/mpich-3.3.2.tar.gz`
2. Extract the file, e.g. `tar -xf mpich-3.3.2.tar.gz`
3. `cd $scratch/dependencies/src/mpich-3.3.2`
4. See the file `setup_mpich.sh` in appendix below, and put this in a bash script, e.g. `$scratch/dependencies/src/mpich-3.3.2/setup_mpich.sh`
5. Modify the `prefix=...` to point to the directory in which you want your dependencies to install.
6. I recommend creating a new bash shell at this point, e.g. running `bash`. We will be setting many environment variables.
7. Run `source setup_mpich.sh`
8. Run `make`
		* In the event of problems, run `make clean` and `make VERBOSE=1`, or see [This document](https://www.mpich.org/static/downloads/3.3.2/mpich-3.3.2-installguide.pdf)
9. If installation is successful, run `make install`
10. Close out of the nested bash shell, e.g. press control-d

####Checks

1. Check the folder that the variable `$prefix` points to. Does it contain `bin`, `include`, `lib`, and `share`?


#### Notes:
When building HDF5 with support for parallel I/O, using either of the OpenMPI versions provided on GreatLakes causes tests in the HDF5 test suite to fail, for more info see [Here](https://forum.hdfgroup.org/t/hdf5-and-openmpi/5437). This is why we install a separate MPI implementation. 

### 3. zlib 1.2.11
1. In your `$scratch/dependencies/src` run `wget http://www.zlib.net/zlib-1.2.11.tar.gz`
2. decompress resulting file, e.g. `tar -xf zlib-1.2.11.tar.gz`
3. `cd $scratch/dependencies/src/zlib-1.2.11`
4. See the file `setup_zlib.sh` below, and put it in a bash script in this folder, e.g. `$scratch/dependencies/src/zlib-1.2.11/setup_zlib.sh`
5. Modify the line `export PATH=$scratch/dependencies/mpich/bin:$PATH` to point to your mpich install bin directory.
6. Modify the line `prefix=...` to point to your zlib install dir.
7. Create a new bash shell, e.g. run `bash`
8. Run `source setup_zlib.sh`
9. Run `make`
10. Run `make check`
11. Run `make install`
12. Close out of the nested bash shell

####Checks:

1. `make check` will test for correct functionality of the compiled libraries.
2. Ensure that libraries are installed in the folder that the `$prefix` variable above points to.

#### Notes:
I only found the `make` commands in `zlib` to fail because the `mpicc` executable created by `mpich` was misconfigured. Ensure that the variable `MPICH_CC` is actually being exported correctly.

### 4. curl 7.71.1
1. In your `$scratch/dependencies/src` directory run `wget https://curl.haxx.se/download/curl-7.71.1.tar.gz`
2. Uncompress the resultant file, e.g. `tar -xf curl-7.71.1.tar.gz`
3. `cd curl-7.71.1`
4. See the script `setup_curl.sh` in the appendix. Copy this to a script in the current directory, e.g. `$scratch/dependencies/src/curl-7.71.1/setup_curl.sh`
5. Ensure that the `export PATH...` line points to your mpich bin install.
6. Set the `$prefix` variable to where curl should be installed.
7. Create a nested bash shell
8. Run `source setup_curl.sh`
9. Run `make`
10. Run `make install`
11. Close out of nested bash shell

### 5. hdf5 1.10.6
1. in your `$scratch/dependencies/src` directory run `wget -O hdf5-1.10.6.tar.gz https://www.hdfgroup.org/package/hdf5-1-10-6-tar-gz/?wpdmdl=14135&refresh=5f161604d93fc1595282948` 
2. Decompress the file, e.g. `tar -xf hdf5-1.10.6.tar.gz`
3. `cd hdf5-1.10.6`
4. See the script `setup_hdf5.sh` below, and transfer it to a script in this directory, e.g. `$scratch/dependencies/src/hdf5-1.10.6/setup_hdf5.sh`.
5. Ensure that the $PATH and $prefix variables are set correctly. See above.
6. Ensure that the $zlib variable points to your zlib install location.
7. Create a nested bash shell
8. Run `source setup_hdf5.sh`
9. Run `make`
10. Run `make check`
11. Run `make install`
12. Close out of nested bash shell.

#### Notes:
The versions up to this point are not all that important, however having a version of hdf5 > 1.10 appears to be important when compiling ParallelIO later.
Also, the `make check` will take a long time. I recommend actually taking the time as if it fails it may silently cause huge problems down the line. 
Note that running `make` before `make check` isn't redundant: tests will fail if you do not run `make` first.

### 6. netcdf-c 4.7.4 (without parallel)
1. In the directory `$scratch/dependencies/src` run `wget https://github.com/Unidata/netcdf-c/archive/v4.7.4.tar.gz`
2. Decompress file, e.g. `tar -xf v4.7.4.tar.gz`
3. `cd netcdf-c-4.7.4`
4. See script `setup_netcdf_c_no_pnetcdf.sh` below. Copy it to the current directory e.g. `$scratch/dependencies/src/netcdf-c-4.7.4/setup_netcdf_c_no_pnetcdf.sh`
5. Ensure that the $prefix and $PATH variables are set correctly. 
6. Ensure that the $zlib and $hdf5 variables point to the install locations you specified previously.
7. Create a nested bash shell
8. run `source setup_netcdf_c_no_pnetcdf.sh`
9. run `make`
10. run `make check`
11. run `make install`
12. Close out of nested bash shell
#### Notes:
Eventually we will need netcdf-c to be compiled with PNetCDF compatibility. However, the PNetCDF library requires netcdf-c as a dependency. Thus we will need to compile both netcdf-c and netcdf-fortran before compiling PNetCDF, and then again afterwards. 

### 7. netcdf-fortran 4.5.3
1. In the directory `$scratch/dependencies/src` run `wget https://github.com/Unidata/netcdf-fortran/archive/v4.5.3.tar.gz`
2. Decompress file, e.g. `tar -xf v4.5.3.tar.gz`
3. `cd netcdf-fortran-4.5.3`
4. See script `setup_netcdf_fortran_no_pnetcdf.sh` in appendix below, and copy it to a script e.g. `$scratch/dependencies/src/netcdf-fortran-4.5.3/setup_netcdf_fortran_no_pnetcdf.sh`
5. Ensure that the $prefix and $PATH variable are set correctly
6. Ensure that the $hdf5, $zlib, $curld, and $NETCDF_C variables are set to the install locations of their respective libraries
7. Create nested bash shell
8. run `source setup_netcdf_fortran_no_pnetcdf.sh`
9. run `make`
10. run `make check`
11. run `make install`
12. Close out of nested bash shell

### 8. pnetcdf 1.11.2
1. In the directory `$scratch/dependencies/src` run `wget http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/pnetcdf-1.11.2.tar.gz`
2. Decompress file, e.g. `tar -xf pnetcdf-1.11.2.tar.gz`
3. `cd pnetcdf-1.11.2`
4. See script `setup_pnetcdf.sh` in appendix, copy to a script in current directory e.g. `$scratch/dependencies/src/pnetcdf-1.11.2/setup_pnetcdf.sh`
5. Ensure that $PATH variable is set correctly, and that the $PNETCDF variable points to the install location for the pnetcdf library.
6. Ensure that the $NETCDF_C and $NETCDF_F variables are set to the install locations of the respective libraries.
7. Create a nested bash shell
8. run `source setup_pnetcdf.sh`
9. run `make`
10. run `make check`
11. run `make ptests`
12. run `make install`
13. Close out of nested bash shell

### 9. netcdf-c with pnetcdf 
Run through previous netcdf-c instructions but with the bash script `setup_netcdf_c_with_pnetcdf.sh` below.

### 10. netcdf-fortran with pnetcdf
Run through previous netcdf-fortran instructions but with the bash script `setup_netcdf_fortran_with_pnetcdf.sh` below.

#### Notes:
This step may not be necessary. I include it out of an abundance of caution and a paranoid distrust of anything to do with the linker.

### 11. ParallelIO (*shudders*)
1. In the directory `$scratch/dependencies/src` run `git clone https://github.com/NCAR/ParallelIO.git` or just ask me for a gzip of the code. See notes below.
2. `cd ParallelIO`
3. See script `setup_PIO.sh` below, and copy it to a script in the current directory, e.g. `$scratch/dependencies/src/ParallelIO/setup_PIO.sh`
4. Ensure that the $PATH and $prefix variables are set correctly
5. Ensure that the $NETCDF_C, $NETCDF_F, $PNETCDF, $hdf5, and $zlib variables point to the install locations of their respective libraries.
6. Create a nested bash shell
7. run `source setup_PIO.sh`
8. run `make`
9. run `make check`
10. run `make install`
11. exit nested bash shell

#### Notes:
When testing this library with any released version from 2.4.3 to 2.5 I could not get tests to pass successfully. As of my writing this there is a new release (2.5.1) which I have not tested. I could only get these tests to pass by cloning the master branch of the repository. If this code has changed since I wrote this, I can send you the gzip of the source.

## Installing MPAS itself:
1. The MPAS installation can be done in a subdirectory of $HOME. In whatever directory you want your MPAS source code in, run `wget https://github.com/MPAS-Dev/MPAS-Model/archive/v7.0.tar.gz`
2. Decompress file, e.g. `tar -xf v7.0.tar.gz`
3. `cd MPAS-Model-7.0`
4. See script `setup_MPAS.sh` below, and copy into a script in this directory.
5. ensure that the $PATH variable is set correctly.
6. ensure that the $NETCDF variable points to your netcdf-c install directory, your $NETCDFF variable points to your netcdf-fortran install directory, your $PIO variable points to your ParallelIO install and your $PNETCDF, $hdf5, and $zlib variables point to their respective libraries' install locations.
7. Create a nested bash shell
8. Run `source setup_MPAS.sh`
7. Run `make gfortran CORE=init_atmosphere PRECISION=single`
8. Run `make clean CORE=atmosphere`
8. Run `make gfortran CORE=atmosphere PRECISION=single`

#### Notes:
See [This tutorial](https://www2.mmm.ucar.edu/projects/mpas/tutorial/Boulder2018/index.html) for more information.




# Appendix:
====================================================================
This appendix contains the bash scripts referenced elsewhere in this document for reference.


## setup_mpich.sh

---

```
  module load gcc/8.2.0
  export CC=gcc
  export CXX=g++
  export FC=gfortran
  export F77=gfortran
  prefix=$scratch/dependencies/mpich
  ./configure --prefix=$prefix --enable-shared
```

---

## setup_zlib.sh

--- 

```
module load gcc/8.2.0
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export CC=mpicc
export FC=mpif90
prefix=$scratch/dependencies/zlib
export LD_LIBRARY_PATH=$scratch/dependencies/mpich/lib:${LD_LIBRARY_PATH}
./configure --prefix=$prefix --enable-shared
```

---

## setup_curl.sh

---

```
module load gcc/8.2.0
module load gcc/8.2.0
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export CC=mpicc
export FC=mpif90
export LD_LIBRARY_PATH=$scratch/dependencies/mpich/lib:${LD_LIBRARY_PATH}
prefix=$HOME/dependencies/curl
./configure --prefix=$prefix --enable-shared
```

---

## setup_hdf5.sh

---

```
module load gcc/8.2.0
export PATH="$scratch/dependencies/mpich/bin:$PATH"
export MPICH_CC=gcc
export MPICH_FC=gfortran
export CC=mpicc
export CXX=mpicc
export FC=mpif90
prefix="$scratch/dependencies/hdf5"
zlib="$scratch/dependencies/zlib"

export LD_LIBRARY_PATH=$scratch/dependencies/mpich/lib:${zlib}/lib:${LD_LIBRARY_PATH}
export LIBS="-ldl"
export CFLAGS="-g"

./configure --prefix=$prefix --with-zlib=$zlib --enable-parallel --enable-shared
```

---

## setup_netcdf_c_no_pnetcdf.sh

---

```
module load gcc/8.2.0
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export MPICH_FC=gfortran
export CC=mpicc
export FC=mpif90
hdf5=$scratch/dependencies/hdf5
zlib=$scratch/dependencies/zlib
prefix=$scratch/dependencies/netcdf_c
export CPPFLAGS="-I$hdf5/include -I$zlib/include"
export LDFLAGS="-L$hdf5/lib -L$zlib/lib"
export LIBS="-ldl -lhdf5"
export CFLAGS="-g -Wall"
export LD_LIBRARY_PATH=$scratch/dependencies/mpich/lib:${zlib}/lib:${hdf5}/lib:${LD_LIBRARY_PATH}
./configure --prefix=$prefix --enable-shared --enable-static --enable-netcdf4 --disable-dap --enable-cdf5
```

---

## setup_netcdf_fortran_no_pnetcdf.sh

---

```
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export MPICH_FC=gfortran
export MPICH_F90=gfortran
export CC=mpicc
export FC=mpif90
export NETCDF_C=$scratch/dependencies/netcdf_c
export prefix=$scratch/dependencies/netcdf_fortran
hdf5=$scratch/dependencies/hdf5
zlib=$scratch/dependencies/zlib
curld=$scratch/dependencies/curl
export CPPFLAGS="-I${NETCDF_C}/include -I$hdf5/include -I$zlib/include -I$curld/include"
export LDFLAGS="-L${NETCDF_C}/lib -L$hdf5/lib -L$zlib/lib -L$curld/lib"
export LIBS="-lnetcdf -lhdf5_hl -lm -lz -ldl -lhdf5"
export LD_LIBRARY_PATH=$scratch/dependencies/mpich/lib:${zlib}/lib:${hdf5}/lib:${NETCDF_C}/lib:${LD_LIBRARY_PATH}
./configure --prefix=$prefix --enable-shared --enable-static
```

---


## setup_pnetcdf.sh

---

```
module load gcc/8.2.0
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export MPICH_FC=gfortran
export MPICH_F90=gfortran
export NETCDF_C=$scratch/dependencies/netcdf_c
export NETCDF_F=$scratch/dependencies/netcdf_fortran
export PNETCDF=$scratch/dependencies/pnetcdf
export CC=mpicc
export CXX=mpic++
export FC=mpif90
export CPPFLAGS="-I$NETCDF_C/include -I$NETCDF_F/include"
export LD_LIBRARY_PATH=$scratch/dependencies/mpich/lib:${zlib}/lib:${hdf5}/lib:${NETCDF_C}/lib:${NETCDF_F}/lib:${LD_LIBRARY_PATH}
prefix=$PNETCDF
./configure --enable-fortran --enable-static --enable-shared --prefix=$prefix
```

---

## setup_netcdf_c_with_pnetcdf.sh

---

```
module load gcc/8.2.0
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export MPICH_FC=gfortran
export CC=mpicc
export FC=mpif90
hdf5=$scratch/dependencies/hdf5
zlib=$scratch/dependencies/zlib
pnetcdf=$scratch/dependencies/pnetcdf
prefix=$scratch/dependencies/netcdf_c
export CPPFLAGS="-I$hdf5/include -I$zlib/include -I$pnetcdf/include"
export LDFLAGS="-L$hdf5/lib -L$zlib/lib -L$pnetcdf/lib"
export LIBS="-ldl -lhdf5 -lpnetcdf"
export CFLAGS="-g -Wall"
export LD_LIBRARY_PATH=$scratch/dependencies/mpich/lib:${zlib}/lib:${hdf5}/lib:${NETCDF_C}/lib:${NETCDF_F}/lib:${pnetcdf}/lib:${LD_LIBRARY_PATH}
./configure --prefix=$prefix --enable-shared --enable-parallel-tests --enable-static --enable-pnetcdf --enable-netcdf4 --disable-dap --enable-cdf5
```

---

## setup_netcdf_fortran_with_pnetcdf.sh

---

```
module load gcc/8.2.0
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export MPICH_FC=gfortran
export MPICH_F90=gfortran
export CC=mpicc
export FC=mpif90
export NETCDF_C=$scratch/dependencies/netcdf_c
export NETCDF_F=$scratch/dependencies/netcdf_fortran
export PNETCDF=$scratch/dependencies/pnetcdf
hdf5=$scratch/dependencies/hdf5
zlib=$scratch/dependencies/zlib
curld=$scratch/dependencies/curl
export CPPFLAGS="-I${NETCDF_C}/include -I$hdf5/include -I$zlib/include -I$curld/include"
export LDFLAGS="-L${NETCDF_C}/lib -L$hdf5/lib -L$zlib/lib -L$curld/lib -L$PNETCDF/lib"
export LIBS="-lnetcdf -lhdf5_hl -lm -lz -ldl -lhdf5 -lpnetcdf"
export LD_LIBRARY_PATH=$scratch/dependencies/mpich/lib:${zlib}/lib:${hdf5}/lib:${NETCDF_C}/lib:${NETCDF_F}/lib:${PNETCDF}/lib:${LD_LIBRARY_PATH}
./configure --prefix=$NETCDF_F --enable-shared --enable-static
```

---

## setup_PIO.sh

--- 

```
module load gcc/8.2.0
module load cmake/3.17.3
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export MPICH_FC=gfortran
export MPICH_F77=gfortran
export MPICH_F90=gfortran
export CC=mpicc
export FC=mpifort
NETCDF_C=$scratch/dependencies/netcdf_c
NETCDF_F=$scratch/dependencies/netcdf_fortran
PNETCDF=$scratch/dependencies/pnetcdf
hdf5=$scratch/dependencies/hdf5
zlib=$scratch/dependencies/zlib
export CPPFLAGS="-I${NETCDF_C}/include -I${NETCDF_F}/include -I${PNETCDF}/include -I$hdf5/include -I$zlib/include -I"
export LDFLAGS="-L${NETCDF_C}/lib -L${NETCDF_F}/lib -L${PNETCDF}/lib -L${hdf5}/lib -L${zlib}/lib"
export LD_LIBRARY_PATH="$PNETCDF/lib:${NETCDF_C}/lib:${NETCDF_F}/lib:${hdf5}/lib:${zlib}/lib:${LD_LIBRARY_PATH}"
export LIBS="-lnetcdf -lpnetcdf -lhdf5_hl -lm -lz -lcurl -ldl -lhdf5"
export CFLAGS="-g -Wall -std=c11"
prefix=$scratch/dependencies/PIO
cmake   -DNetCDF_C_PATH=$NETCDF_C -DNetCDF_Fortran_PATH=$NETCDF_F -DPnetCDF_PATH=$PNETCDF -DHDF5_PATH=$hdf5 -DCMAKE_INSTALL_PREFIX=$prefix -DPIO_USE_MALLOC=ON -DCMAKE_VERBOSE_MAKEFILE=true -DPIO_ENABLE_TIMING=OFF
```

---

## setup_MPAS.sh

---

```
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
export LD_LIBRARY_PATH="${PIO}/lib:$PNETCDF/lib:${NETCDF_C}/lib:${NETCDF_F}/lib:${hdf5}/lib:${zlib}/lib:${LD_LIBRARY_PATH}"
export FFLAGS="-freal-4-real-8"
```

---
