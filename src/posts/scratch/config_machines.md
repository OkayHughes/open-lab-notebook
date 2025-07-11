---
date: 2021-08-31
tags:
  - posts
  - directory
eleventyNavigation:
  key: config_machines.xml
  parent: scratch
layout: layouts/post.njk
---

```
<?xml version="1.0"?>
<!-- This is an ordered list, not all fields are required, optional fields are noted below. -->
<config_machines version="2.0">
<!-- MACH is the name that you will use in machine options -->

  <machine MACH="greatlakes">

    <!-- DESC: a text description of the machine, this field is current not used in code-->
    <DESC>UMich Great Lakes cluster, os is Linux, 36 PES/node, batch system is SLURM, GPFS on /scratch</DESC>

    <!-- NODENAME_REGEX: a regular expression used to identify this machine
	  it must work on compute nodes as well as login nodes, use machine option
	  to create_test or create_newcase if this flag is not available -->
    <NODENAME_REGEX>gl.*\.arc-ts\.umich.edu</NODENAME_REGEX>

    <!-- OS: the operating system of this machine. Passed to cppflags for
	 compiled programs as -DVALUE  recognized are LINUX, AIX, Darwin, CNL -->
    <OS>LINUX</OS>

    <!-- PROXY: optional http proxy for access to the internet-->
    <PROXY>  </PROXY>

    <!-- COMPILERS: compilers supported on this machine, comma seperated list, first is default -->
    <COMPILERS>gnu,intel</COMPILERS>

    <!-- MPILIBS: mpilibs supported on this machine, comma seperated list,
	     first is default, mpi-serial is assumed and not required in this list-->
    <MPILIBS>openmpi</MPILIBS>

    <!-- PROJECT: A project or account number used for batch jobs
         This value is used for directory names. If different from
         actual accounting project id, use CHARGE_ACCOUNT
	 can be overridden in environment or $HOME/.cime/config -->
    <!--PROJECT>my_cesm_project_placeholder</PROJECT-->

    <!-- CHARGE_ACCOUNT: A project or account number used for batch jobs
	 This is the actual project used for cost accounting set in
         the batch script (ex. #PBS -A charge_account). Will default
         to PROJECT if not set.
	 can be overridden in environment or $HOME/.cime/config -->
    <!-- <CHARGE_ACCOUNT>$ENV{MY_SLURM_ACCOUNT}</CHARGE_ACCOUNT> -->

    <!-- SAVE_TIMING_DIR: (Acme only) directory for archiving timing output -->
    <!-- SAVE_TIMING_DIR> </SAVE_TIMING_DIR -->

    <!-- SAVE_TIMING_DIR_PROJECTS: (Acme only) projects whose jobs archive timing output -->
    <!-- SAVE_TIMING_DIR_PROJECTS> </SAVE_TIMING_DIR_PROJECTS -->

    <!-- CIME_OUTPUT_ROOT: Base directory for case output,
	 the case/bld and case/run directories are written below here -->
    <CIME_OUTPUT_ROOT>$ENV{MY_E3SM_SCRATCH}/E3SMv2</CIME_OUTPUT_ROOT>

    <!-- DIN_LOC_ROOT: location of the inputdata data directory
	 inputdata is downloaded automatically on a case by case basis as
	 long as the user has write access to this directory.   We recommend that
	 all cime model users on a system share an inputdata directory
	 as it can be quite large -->
    <DIN_LOC_ROOT>$ENV{DIN_LOC_ROOT}</DIN_LOC_ROOT>

    <!-- DIN_LOC_ROOT_CLMFORC: override of DIN_LOC_ROOT specific to CLM
	 forcing data -->
    <DIN_LOC_ROOT_CLMFORC>$ENV{MY_E3SM_ROOT}/shared_lmwg</DIN_LOC_ROOT_CLMFORC>

    <!-- DOUT_S_ROOT: root directory of short term archive files, short term
      archiving moves model output data out of the run directory, but
      keeps it on disk-->
    <DOUT_S_ROOT>$CIME_OUTPUT_ROOT/archive/$CASE</DOUT_S_ROOT>

    <!-- BASELINE_ROOT:  Root directory for system test baseline files -->
    <BASELINE_ROOT>$ENV{MY_E3SM_ROOT}/e3sm_baselines</BASELINE_ROOT>

    <!-- CCSM_CPRNC: location of the cprnc tool, compares model output in testing-->
    <CCSM_CPRNC>$ENV{MY_E3SM_ROOT}/cime/tools/cprnc/</CCSM_CPRNC>

    <!-- GMAKE: gnu compatible make tool, default is 'gmake' -->
    <GMAKE>make</GMAKE>

    <!-- GMAKE_J: optional number of threads to pass to the gmake flag -->
    <GMAKE_J>8</GMAKE_J>

    <!-- BATCH_SYSTEM: batch system used on this machine,
      supported values are: none, cobalt, lsf, pbs, slurm -->
    <BATCH_SYSTEM>slurm</BATCH_SYSTEM>

    <!-- SUPPORTED_BY: contact information for support for this system
      this field is not used in code -->
    <SUPPORTED_BY>arcts-support@umich.edu</SUPPORTED_BY>

    <!-- MAX_TASKS_PER_NODE: maximum number of threads*tasks per
	 shared memory node on this machine,
	 should always be >= MAX_MPITASKS_PER_NODE -->
    <MAX_TASKS_PER_NODE>36</MAX_TASKS_PER_NODE>

    <!-- MAX_MPITASKS_PER_NODE: number of physical PES per shared node on
	 this machine, in practice the MPI tasks per node will not exceed this value -->
    <MAX_MPITASKS_PER_NODE>36</MAX_MPITASKS_PER_NODE>

    <!-- PROJECT_REQUIRED: Does this machine require a project to be specified to
	 the batch system?  See PROJECT above -->
    <PROJECT_REQUIRED>FALSE</PROJECT_REQUIRED>

    <!-- mpirun: The mpi exec to start a job on this machine, supported values
	 are values listed in MPILIBS above, default and mpi-serial -->
    <mpirun mpilib="openmpi">
      <!-- name of the exectuable used to launch mpi jobs -->
      <executable>mpiexec</executable>
      <!-- arguments to the mpiexec command, the name attribute here is ignored-->
      <arguments>
	<arg name="num_tasks">-n {{ total_tasks }}</arg>
      </arguments>
    </mpirun>
    <mpirun mpilib="mpi-serial">
      <executable></executable>
    </mpirun>
    <!-- module system: allowed module_system type values are:
	 module  http://www.tacc.utexas.edu/tacc-projects/mclay/lmod
	 soft http://www.mcs.anl.gov/hs/software/systems/softenv/softenv-intro.html
         none
      -->
    <module_system type="module" allow_error="true">
      <init_path lang="perl">/sw/arcts/centos7/lmod/lmod/init/perl</init_path>
      <init_path lang="python">/sw/arcts/centos7/lmod/lmod/init/env_modules_python.py</init_path>
      <init_path lang="csh">/sw/arcts/centos7/lmod/lmod/init/csh</init_path>
      <init_path lang="sh">/sw/arcts/centos7/lmod/lmod/init/sh</init_path>

      <cmd_path lang="perl">/sw/arcts/centos7/lmod/lmod/libexec/lmod perl</cmd_path>
      <cmd_path lang="python">/sw/arcts/centos7/lmod/lmod/libexec/lmod python</cmd_path>
      <cmd_path lang="sh">module</cmd_path>
      <cmd_path lang="csh">module</cmd_path>

      <modules compiler="gnu">
        <command name="purge"></command>
        <command name="load">gcc/8.2.0</command>
        <!-- <command name="load">openmpi/4.0.2</command> --> <!-- Does not work on GL! -->
	<command name="load">mkl/2018.0.4</command>
        <command name="load">openmpi/3.1.4</command> <!-- Has bugs openmpi/3.1.4 but seems to work! -->
        <command name="load">cmake/3.17.3</command> <!-- JH: for CESM, was 3.13.2; E3SM needs >=3.16-->
        <command name="load">hdf5/1.8.21</command>
        <command name="load">netcdf-c/4.6.2</command>
        <command name="load">netcdf-fortran/4.4.5</command>
      </modules>
      <modules compiler="intel">
        <command name="purge"></command>
        <!-- <command name="load">intel/19.1</command> -->
        <command name="load">intel/18.0.5</command>
        <!-- <command name="load">intel/14.0.2</command> -->
        <!-- <command name="load">openmpi/4.0.2</command> --> <!-- Does not work on GL! -->
        <command name="load">openmpi/3.1.4</command> <!-- Has bugs openmpi/3.1.4 but seems to work! -->
        <command name="load">cmake/3.17.3</command> <!-- JH: for CESM, was 3.13.2; E3SM needs >=3.16-->
        <command name="load">hdf5/1.8.21</command>
        <command name="load">netcdf-c/4.6.2</command>
        <command name="load">netcdf-fortran/4.4.5</command>
      </modules>
    </module_system>

    <!-- environment variables, a blank entry will unset a variable -->
    <environment_variables>
      <env name="NETCDF_C_PATH">$ENV{NCDIR}</env>
      <env name="NETCDF_FORTRAN_PATH">$ENV{NFDIR}</env>
      <env name="LD_LIBRARY_PATH">$ENV{LD_LIBRARY_PATH}</env>
      <env name="PATH">/sw/arcts/centos7/gcc/8.2.0/bin/gcc:$ENV{PATH}</env>
      <env name="OMP_STACKSIZE">256M</env>
      <!--env name="MPI_TYPE_DEPTH">16</env-->
    </environment_variables>
    <!-- resource settings as defined in https://docs.python.org/2/library/resource.html -->
    <resource_limits>
      <resource name="RLIMIT_STACK">-1</resource>
    </resource_limits>
  </machine>

</config_machines>

```