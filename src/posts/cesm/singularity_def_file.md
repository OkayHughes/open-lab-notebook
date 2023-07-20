---
date: 2021-09-01
tags:
  - posts
  - regridding
eleventyNavigation:
  key: A singularity container for CESM
  parent: Community Earth System Model lifehacks
layout: layouts/post.njk
---

# cesm.def

```
Bootstrap: docker
From: almalinux:8.6


%post
tee > /tmp/oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF
    mv /tmp/oneAPI.repo /etc/yum.repos.d

    dnf -y update
    dnf install -y epel-release
    dnf install -y intel-basekit
    dnf -y install gcc-gfortran
    dnf update -y && \
        dnf groupinstall -y 'Development Tools' && \
        dnf install -y \
        openssl-devel \
        libuuid-devel \
        libseccomp-devel \
        wget \
        squashfs-tools


    dnf -y install cmake
    dnf install -y python3 svn vim
    export PATH="/usr/local/bin:$PATH"
    ln -s /bin/python3 /bin/python
    env python
    


    hostname singularity

    mkdir -p /usr/local/
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
    ./configure --prefix=/usr/local/
    make -j32 && make -j32 install
    cd ..

    export CFLAGS='-I/usr/local/include'
    export CXXFLAGS='-I/usr/local/include'
    export LDFLAGS='-L/usr/local/lib'
    export LD_LIBRARY_PATH="/usr/local/lib/:/usr/local/lib64:$LD_LIBRARY_PATH"



    # build parallel szip
    tar xzf szip-2.1.1.tar.gz
    cd szip-2.1.1
   export CC=mpicc
    export CXX=mpicxx
    export FC=mpif90
    ./configure 
    make -j32 && make -j32 install
    cd ..

    # build parallel hdf5
    rm -rf hdf5-1.10.6
    tar xzf hdf5-1.10.6.tar.gz
    cd hdf5-1.10.6
    export CC=mpicc
    export MPICC=mpicc
    export CXX=mpicxx
    export MPICXX=mpicxx
    export FC=mpif90
    export MPIF90=mpif90
    export MPIFC=mpif90
    ./configure  --prefix=/usr/local  --enable-parallel --enable-shared
    make -j32 && make -j32 install
    cd ..
    # build serial netcdf
    tar xzf v4.7.3.tar.gz
    cd netcdf-c-4.7.3
    ./configure --prefix=/usr/local --disable-dap --enable-netcdf-4 --enable-static
    make -j32 && make -j32 install
    cd ..

    tar xzf v4.3.1.tar.gz
    cd netcdf-cxx4-4.3.1
    ./configure  --prefix=/usr/local --disable-dap --enable-netcdf-4 --enable-static
    make -j32 && make -j32  install
    cd ..



    tar xzf v4.4.4.tar.gz
    cd netcdf-fortran-4.4.4
    ./configure  --prefix=/usr/local --disable-dap --enable-netcdf-4 --enable-static --enable-valgrind-tests --enable-serial-tests --enable-extra-tests --enable-extra-example-tests
    make -j32 && make -j32 install
    cd ..

    # build parallel netcdf
    rm -rf netcdf-c-4.7.3
    tar xzf v4.7.3.tar.gz
    cd netcdf-c-4.7.3
    ./configure  --prefix=/usr/local --disable-dap --enable-netcdf-4 --enable-static 
    make -j32 && make -j32 install
    cd ..

    rm -rf netcdf-cxx4-4.3.1
    tar xzf v4.3.1.tar.gz
    cd netcdf-cxx4-4.3.1
    cd ..

    rm -rf netcdf-fortran-4.4.4
    tar xzf v4.4.4.tar.gz 
    cd netcdf-fortran-4.4.4
    ./configure  --prefix=/usr/local  --disable-dap --enable-netcdf-4 --enable-static --enable-valgrind-tests --enable-parallel-tests --enable-extra-tests --enable-extra-example-tests
    make -j32 && make -j32 install
    cd ..


    # build pnetcdf
    tar xzf pnetcdf-1.12.1.tar.gz
    cd pnetcdf-1.12.1
    ./configure  --prefix=/usr/local  --disable-in-place-swap
    make -j32 && make -j32 install

    mkdir -p /opt
    git clone https://github.com/escomp/cesm.git /opt/cesm_2.1.3
    cd /opt/cesm_2.1.3
    git checkout release-cesm2.1.3
#    chmod 755 /opt/cesm_2.1.3
```

#

