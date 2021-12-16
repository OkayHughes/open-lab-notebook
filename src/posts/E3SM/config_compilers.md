---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: config_compilers.xml
  parent: Installing E3SM 2.0 on Greatlakes using my jank MPAS dependencies
layout: layouts/post.njk
---

```
<?xml version="1.0" encoding="UTF-8"?>
<config_compilers version="2.0">

<!-- Comments below mostly indicate departures from the form of this file for the CESM GreatLakes install -->




<!-- The header of this file indicates that we should not use SLIBS here-->
<!-- https://github.com/E3SM-Project/E3SM/blob/e3d7f9bce027f99a021dedf15929d0dba1b8bacb/cime/config/e3sm/machines/config_compilers.xml -->
<!-- define LDFLAGS below instead -->
<!--
<compiler MACH="greatlakes">

  <SLIBS>
    <append> -llapack -lblas </append>
  </SLIBS>
  
</compiler>
-->

<compiler COMPILER="gnu" MACH="greatlakes">

  <HDF5_PATH> $ENV{HDF5_PATH}</HDF5_PATH>
  <NETCDF_C_PATH> $ENV{NETCDF_C_PATH}</NETCDF_C_PATH>
  <NETCDF_FORTRAN_PATH> $ENV{NETCDF_F_PATH}</NETCDF_FORTRAN_PATH>
  <PNETCDF_PATH> $ENV{PNETCDF_PATH}</PNETCDF_PATH>
  <SLIBS>
    <append> $SHELL{$NETCDF_C_PATH/bin/nc-config --libs} $SHELL{$NETCDF_FORTRAN_PATH/bin/nf-config --flibs} -lblas -llapack </append>
  </SLIBS> 
</compiler>

</config_compilers>
```