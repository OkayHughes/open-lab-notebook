---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: e3sm.def
  parent: Singularity Container
layout: layouts/post.njk
---

```
Bootstrap: library
From: ubuntu:18.04

%post
    apt-get update
    apt-get -y install software-properties-common
    add-apt-repository universe
    apt-get -y install apt-transport-https ca-certificates gnupg \
                         software-properties-common wget
    wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add -
    apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
    apt-get update
    apt-get -y install cmake
    apt-get -y install gcc-8 g++-8 gfortran-8
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 10
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 10
     update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-8 10
    apt-get update && apt-get -y install locales csh python m4 libcurl4-openssl-dev libz-dev liblapack-dev make git subversion libxml2-utils libxml-libxml-perl libswitch-perl python3-distutils
    locale-gen en_US.UTF-8
    hostname singularity

    mkdir -p /usr/local/packages
    mkdir -p /usr/local/sources
    cd /usr/local/sources
    wget --inet4-only http://www.mpich.org/static/downloads/3.3.2/mpich-3.3.2.tar.gz
    wget --inet4-only https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz
    wget --inet4-only https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_1_10_6/source/hdf5-1.10.6.tar.gz
    wget --inet4-only https://github.com/Unidata/netcdf-c/archive/v4.7.3.tar.gz
    wget --inet4-only https://github.com/Unidata/netcdf-cxx4/archive/v4.3.1.tar.gz
    wget --inet4-only https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz
    wget --inet4-only https://parallel-netcdf.github.io/Release/pnetcdf-1.12.1.tar.gz

    # build mpich
    tar xzf mpich-3.3.2.tar.gz
    cd mpich-3.3.2
    export CC=gcc
    export CXX=g++
    export FC=gfortran
    ./configure --prefix=/usr/local/packages/mpich
    make -j4 && make -j4 install
    cd ..

    # build parallel szip
    tar xzf szip-2.1.1.tar.gz
    cd szip-2.1.1
    export CC=/usr/local/packages/mpich/bin/mpicc
    export CXX=/usr/local/packages/mpich/bin/mpicxx
    export FC=/usr/local/packages/mpich/bin/mpif90
    ./configure --prefix=/usr/local/packages/szip
    make -j4 && make -j4 install
    cd ..

    # build serial hdf5
    tar xzf hdf5-1.10.6.tar.gz
    cd hdf5-1.10.6
    export CC=gcc
    export CXX=g++
    export F77=gfortran
    export FC=gfortran
    ./configure --prefix=/usr/local/packages/hdf5-serial --with-szlib=/usr/local/packages/szip --disable-parallel
    make -j4 && make -j4 install
    cd ..

    # build parallel hdf5
    rm -rf hdf5-1.10.6
    tar xzf hdf5-1.10.6.tar.gz
    cd hdf5-1.10.6
    export CC=/usr/local/packages/mpich/bin/mpicc
    export MPICC=/usr/local/packages/mpich/bin/mpicc
    export CXX=/usr/local/packages/mpich/bin/mpicxx
    export MPICXX=/usr/local/packages/mpich/bin/mpicxx
    export FC=/usr/local/packages/mpich/bin/mpif90
    export MPIF90=/usr/local/packages/mpich/bin/mpif90
    export MPIFC=/usr/local/packages/mpich/bin/mpif90
    ./configure --prefix=/usr/local/packages/hdf5-parallel --with-szlib=/usr/local/packages/szip --enable-parallel
    make -j4 && make -j4 install
    cd ..

    # build serial netcdf
    tar xzf v4.7.3.tar.gz
    cd netcdf-c-4.7.3
    export CC=gcc
    export MPICC=/usr/local/packages/mpich/bin/mpicc
    export CXX=g++
    export MPICXX=/usr/local/packages/mpich/bin/mpicxx
    export F77=gfortran
    export MPIF77=/usr/local/packages/mpich/bin/mpif77
    export FC=gfortran
    export MPIF90=/usr/local/packages/mpich/bin/mpif90
    export MPIFC=/usr/local/packages/mpich/bin/mpif90
    export CFLAGS='-I/usr/local/packages/hdf5-serial/include -I/usr/local/packages/szip/include'
    export CXXFLAGS='-I/usr/local/packages/hdf5-serial/include -I/usr/local/packages/szip/include'
    export LDFLAGS='-L/usr/local/packages/hdf5-serial/lib -L/usr/local/packages/szip/lib'
    ./configure --prefix=/usr/local/packages/netcdf-serial --disable-dap --enable-netcdf-4 --disable-shared --enable-static --with-hdf5=/usr/local/packages/hdf5-serial --with-szlib=/usr/local/packages/szip
    make -j4 && make -j4 install
    cd ..

    tar xzf v4.3.1.tar.gz
    cd netcdf-cxx4-4.3.1
    export CC=gcc
    export MPICC=/usr/local/packages/mpich/bin/mpicc
    export CXX=g++
    export MPICXX=/usr/local/packages/mpich/bin/mpicxx
    export F77=gfortran
    export MPIF77=/usr/local/packages/mpich/bin/mpif77
    export FC=gfortran
    export MPIF90=/usr/local/packages/mpich/bin/mpif90
    export MPIFC=/usr/local/packages/mpich/bin/mpif90
    export CFLAGS='-static -I/usr/local/packages/netcdf-serial/include -I/usr/local/packages/hdf5-serial/include -I/usr/local/packages/szip/include'
    export CXXFLAGS='-static -I/usr/local/packages/netcdf-serial/include -I/usr/local/packages/hdf5-1.10.6-serial/include -I/usr/local/packages/szip/include'
    export LDFLAGS='-L/usr/local/packages/netcdf-serial/lib -L/usr/local/packages/hdf5-serial/lib -L/usr/local/packages/szip/lib'
    export LIBS='-lnetcdf -lhdf5_hl -lhdf5 -ldl -lsz -lm -lz'
    ./configure --prefix=/usr/local/packages/netcdf-serial --disable-dap --enable-netcdf-4 --disable-shared --enable-static --with-hdf5=/usr/local/packages/hdf5-serial --with-szlib=/usr/local/packages/szip
    make -j4 && make -j4  install
    cd ..

    tar xzf v4.4.4.tar.gz
    cd netcdf-fortran-4.4.4
    export CC=gcc
    export MPICC=/usr/local/packages/mpich/bin/mpicc
    export CXX=g++
    export MPICXX=/usr/local/packages/mpich/bin/mpicxx
    export F77=gfortran
    export MPIF77=/usr/local/packages/mpich/bin/mpif77
    export FC=gfortran
    export MPIF90=/usr/local/packages/mpich/bin/mpif90
    export MPIFC=/usr/local/packages/mpich/bin/mpif90
    export CFLAGS='-static -I/usr/local/packages/netcdf-serial/include -I/usr/local/packages/hdf5-serial/include -I/usr/local/packages/szip/include'
    export CXXFLAGS='-static -I/usr/local/packages/netcdf-serial/include -I/usr/local/packages/hdf5-serial/include -I/usr/local/packages/szip/include'
    export FFLAGS='-static -I/usr/local/packages/netcdf-serial/include -I/usr/local/packages/hdf5-serial/include -I/usr/local/packages/szip/include'
    export FCFLAGS='-static -I/usr/local/packages/netcdf-serial/include -I/usr/local/packages/hdf5-serial/include -I/usr/local/packages/szip/include'
    export LDFLAGS='-L/usr/local/packages/netcdf-serial/lib -L/usr/local/packages/hdf5-serial/lib -L/usr/local/packages/szip/lib'
    export LIBS='-lnetcdf -lhdf5_hl -lhdf5 -ldl -lsz -lm -lz'
    ./configure --prefix=/usr/local/packages/netcdf-serial  --disable-dap --enable-netcdf-4 --disable-shared --enable-static --with-hdf5=/usr/local/packages/hdf5-serial --with-szlib=/usr/local/packages/szip--enable-valgrind-tests --enable-serial-tests --enable-extra-tests --enable-extra-example-tests
    make -j4 && make -j4 install
    cd ..

    # build parallel netcdf
    rm -rf netcdf-c-4.7.3
    tar xzf v4.7.3.tar.gz
    cd netcdf-c-4.7.3
    export CC=/usr/local/packages/mpich/bin/mpicc
    export MPICC=/usr/local/packages/mpich/bin/mpicc
    export CXX=/usr/local/packages/mpich/bin/mpicxx
    export MPICXX=/usr/local/packages/mpich/bin/mpicxx
    unset F77
    unset MPIF77
    export FC=/usr/local/packages/mpich/bin/mpif90
    export MPIF90=/usr/local/packages/mpich/bin/mpif90
    export MPIFC=/usr/local/packages/mpich/bin/mpif90
    export CFLAGS='-I/usr/local/packages/hdf5-parallel/include -I/usr/local/packages/szip/include'
    export CXXFLAGS='-I/usr/local/packages/hdf5-parallel/include -I/usr/local/packages/szip/include'
    unset FFLAGS
    unset FCFLAGS
    export LDFLAGS='-L/usr/local/packages/hdf5-parallel/lib -L/usr/local/packages/szip/lib'
    unset LIBS
    ./configure --prefix=/usr/local/packages/netcdf-parallel --disable-dap --enable-netcdf-4 --disable-shared --enable-static --with-hdf5=/usr/local/packages/hdf5-parallel --with-szlib=/usr/local/packages/szip
    make -j4 && make -j4 install
    cd ..

    rm -rf netcdf-cxx4-4.3.1
    tar xzf v4.3.1.tar.gz
    cd netcdf-cxx4-4.3.1
    export CC=/usr/local/packages/mpich/bin/mpicc
    export MPICC=/usr/local/packages/mpich/bin/mpicc
    export CXX=/usr/local/packages/mpich/bin/mpicxx
    export MPICXX=/usr/local/packages/mpich/bin/mpicxx
    export FC=/usr/local/packages/mpich/bin/mpif90
    export MPIF90=/usr/local/packages/mpich/bin/mpif90
    export MPIFC=/usr/local/packages/mpich/bin/mpif90
    export CFLAGS='-static -I/usr/local/packages/netcdf-parallel/include -I/usr/local/packages/hdf5-parallel/include -I/usr/local/packages/szip/include'
    export CXXFLAGS='-static -I/usr/local/packages/netcdf-parallel/include -I/usr/local/packages/hdf5-parallel/include -I/usr/local/packages/szip/include'
    export LDFLAGS='-L/usr/local/packages/netcdf-parallel/lib -L/usr/local/packages/hdf5-parallel/lib -L/usr/local/packages/szip/lib'
    export LIBS='-lnetcdf -lhdf5_hl -lhdf5 -ldl -lsz -lm -lz'
    ./configure --prefix=/usr/local/packages/netcdf-parallel --disable-dap --enable-netcdf-4 --disable-shared --enable-static --with-hdf5=/usr/local/packages/hdf5-parallel --with-szlib=/usr/local/packages/szip
    make -j4 && make -j4 install
    cd ..

    rm -rf netcdf-fortran-4.4.4
    tar xzf v4.4.4.tar.gz 
    cd netcdf-fortran-4.4.4
    export CC=/usr/local/packages/mpich/bin/mpicc
    export MPICC=/usr/local/packages/mpich/bin/mpicc
    export CXX=/usr/local/packages/mpich/bin/mpicxx
    export MPICXX=/usr/local/packages/mpich/bin/mpicxx
    export F77=/usr/local/packages/mpich/bin/mpif77
    export MPIF77=/usr/local/packages/mpich/bin/mpif77
    export FC=/usr/local/packages/mpich/bin/mpif90
    export MPIF90=/usr/local/packages/mpich/bin/mpif90
    export MPIFC=/usr/local/packages/mpich/bin/mpif90
    export CFLAGS='-static -I/usr/local/packages/netcdf-parallel/include -I/usr/local/packages/hdf5-parallel/include -I/usr/local/packages/szip/include'
    export CXXFLAGS='-static -I/usr/local/packages/netcdf-parallel/include -I/usr/local/packages/hdf5-parallel/include -I/usr/local/packages/szip/include'
    export FFLAGS='-static -I/usr/local/packages/netcdf-parallel/include -I/usr/local/packages/hdf5-parallel/include -I/usr/local/packages/szip/include'
    export FCFLAGS='-static -I/usr/local/packages/netcdf-parallel/include -I/usr/local/packages/hdf5-parallel/include -I/usr/local/packages/szip/include'
    export LDFLAGS='-L/usr/local/packages/netcdf-parallel/lib -L/usr/local/packages/hdf5-parallel/lib -L/usr/local/packages/szip/lib'
    export LIBS='-lnetcdf -lhdf5_hl -lhdf5 -ldl -lsz -lm -lz'
    ./configure --prefix=/usr/local/packages/netcdf-parallel  --disable-dap --enable-netcdf-4 --disable-shared --enable-static --with-hdf5=/usr/local/packages/hdf5-parallel --with-szlib=/usr/local/packages/szip--enable-valgrind-tests --enable-parallel-tests --enable-extra-tests --enable-extra-example-tests
    make -j4 && make -j4 install
    cd ..


    # build pnetcdf
    tar xzf pnetcdf-1.12.1.tar.gz
    cd pnetcdf-1.12.1
    export CC=/usr/local/packages/mpich/bin/mpicc
    export MPICC=/usr/local/packages/mpich/bin/mpicc
    export CXX=/usr/local/packages/mpich/bin/mpicxx
    export MPICXX=/usr/local/packages/mpich/bin/mpicxx
    unset F77
    unset MPIF77
    export FC=/usr/local/packages/mpich/bin/mpif90
    export MPIF90=/usr/local/packages/mpich/bin/mpif90
    export MPIFC=/usr/local/packages/mpich/bin/mpif90
    unset CFLAGS
    unset CXXFLAGS
    unset FFLAGS
    unset FCFLAGS
    unset LDFLAGS
    unset LIBS
    ./configure --prefix=/usr/local/packages/pnetcdf --disable-in-place-swap
    make -j4 && make -j4 install
```


