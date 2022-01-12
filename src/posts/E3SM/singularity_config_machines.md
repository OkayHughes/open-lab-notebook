---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: config_machines.xml
  parent: Installing E3SM 2.0 on Greatlakes using my jank MPAS dependencies
layout: layouts/post.njk
---

```
<?xml version="1.0"?>
<!-- This is an ordered list, not all fields are required, optional fields are noted below. -->
<config_machines version="2.0">
<!-- MACH is the name that you will use in machine options -->

  <machine MACH="singularity">
    <DESC>Singularity container</DESC>
    <NODENAME_REGEX>singularity</NODENAME_REGEX>
    <OS>LINUX</OS>
    <COMPILERS>gnu</COMPILERS>
    <MPILIBS>mpich</MPILIBS>
    <CIME_OUTPUT_ROOT>$ENV{MY_E3SM_SCRATCH}/E3SMv2</CIME_OUTPUT_ROOT>
    <DIN_LOC_ROOT>$ENV{DIN_LOC_ROOT}</DIN_LOC_ROOT>
    <DIN_LOC_ROOT_CLMFORC>$ENV{MY_E3SM_ROOT}/shared_lmwg</DIN_LOC_ROOT_CLMFORC>
    <DOUT_S_ROOT>$CIME_OUTPUT_ROOT/archive/$CASE</DOUT_S_ROOT>
    <BASELINE_ROOT>$ENV{MY_E3SM_ROOT}/e3sm_baselines</BASELINE_ROOT>
    <CCSM_CPRNC>$ENV{MY_E3SM_ROOT}/cime/tools/cprnc/</CCSM_CPRNC>
    <GMAKE>make</GMAKE>
    <GMAKE_J>8</GMAKE_J>
    <TESTS>e3sm_developer</TESTS>
    <BATCH_SYSTEM>none</BATCH_SYSTEM>
    <SUPPORTED_BY>lukasz at uchicago dot edu</SUPPORTED_BY>
    <MAX_TASKS_PER_NODE>36</MAX_TASKS_PER_NODE>
    <MAX_MPITASKS_PER_NODE>36</MAX_MPITASKS_PER_NODE>
    <mpirun mpilib="default">
      <executable>mpirun</executable>
      <arguments>
        <arg name="num_tasks"> -launcher fork -hosts localhost -bind-to=core -np {{ total_tasks }}</arg>
      </arguments>
    </mpirun>
    <module_system type="none"/>
    <RUNDIR>$CIME_OUTPUT_ROOT/$CASE/run</RUNDIR>
    <EXEROOT>$CIME_OUTPUT_ROOT/$CASE/bld</EXEROOT>
    <environment_variables>
      <env name="E3SM_SRCROOT">$SRCROOT</env>
    </environment_variables>
    <environment_variables mpilib="mpi-serial">
      <env name="NETCDF_PATH">/usr/local/packages/netcdf-serial</env>
      <env name="PATH">/usr/local/packages/cmake/bin:/usr/local/packages/hdf5-serial/bin:/usr/local/packages/netcdf-serial/bin:$ENV{PATH}</env>
      <env name="LD_LIBRARY_PATH">/usr/local/packages/szip/lib:/usr/local/packages/hdf5-serial/lib:/usr/local/packages/netcdf-serial/lib</env>
    </environment_variables>
    <environment_variables mpilib="!mpi-serial">
      <env name="NETCDF_PATH">/usr/local/packages/netcdf-parallel</env>
      <env name="PNETCDF_PATH">/usr/local/packages/pnetcdf</env>
      <env name="HDF5_PATH">/usr/local/packages/hdf5-parallel</env>
      <env name="PATH">/usr/local/packages/cmake/bin:/usr/local/packages/mpich/bin/:/usr/local/packages/hdf5-parallel/bin:/usr/local/packages/netcdf-parallel/bin:/usr/local/packages/pnetcdf/bin:$ENV{PATH}</env>
      <env name="LD_LIBRARY_PATH">/usr/local/packages/mpich/lib:/usr/local/packages/szip/lib:/usr/local/packages/hdf5-parallel/lib:/usr/local/packages/netcdf-parallel/lib:/usr/local/packages/pnetcdf/lib</env>
    </environment_variables>
  </machine>

</config_machines>
```