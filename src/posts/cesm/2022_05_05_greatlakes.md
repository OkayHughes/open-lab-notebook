---
date: 2021-09-01
tags:
  - posts
  - cesm
eleventyNavigation:
  key: 2022/05/05 CAM FV3 install on UM GreatLakes system
  parent: Community Earth System Model lifehacks
layout: layouts/post.njk
---


## Reconfiguring the build system to work with the new CMake CIME infrastructure

## Unchanged xml machine file:

<details>
<summary> <code>~/.cime/config_machines.xml</code></summary>

<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #75715e">&lt;?xml version=&quot;1.0&quot;?&gt;</span>
<span style="color: #75715e">&lt;!-- This is an ordered list, not all fields are required, optional fields are noted below. --&gt;</span>
<span style="color: #f92672">&lt;config_machines</span> <span style="color: #a6e22e">version=</span><span style="color: #e6db74">&quot;2.0&quot;</span><span style="color: #f92672">&gt;</span>
<span style="color: #75715e">&lt;!-- MACH is the name that you will use in machine options --&gt;</span>

  <span style="color: #f92672">&lt;machine</span> <span style="color: #a6e22e">MACH=</span><span style="color: #e6db74">&quot;greatlakes&quot;</span><span style="color: #f92672">&gt;</span>

    <span style="color: #75715e">&lt;!-- DESC: a text description of the machine, this field is current not used in code--&gt;</span>
    <span style="color: #f92672">&lt;DESC&gt;</span>UMich Great Lakes cluster, os is Linux, 36 PES/node, batch system is SLURM, GPFS on /scratch<span style="color: #f92672">&lt;/DESC&gt;</span>

    <span style="color: #75715e">&lt;!-- NODENAME_REGEX: a regular expression used to identify this machine</span>
<span style="color: #75715e">	  it must work on compute nodes as well as login nodes, use machine option</span>
<span style="color: #75715e">	  to create_test or create_newcase if this flag is not available --&gt;</span>
    <span style="color: #f92672">&lt;NODENAME_REGEX&gt;</span>gl.*\.arc-ts\.umich.edu<span style="color: #f92672">&lt;/NODENAME_REGEX&gt;</span>

    <span style="color: #75715e">&lt;!-- OS: the operating system of this machine. Passed to cppflags for</span>
<span style="color: #75715e">	 compiled programs as -DVALUE  recognized are LINUX, AIX, Darwin, CNL --&gt;</span>
    <span style="color: #f92672">&lt;OS&gt;</span>LINUX<span style="color: #f92672">&lt;/OS&gt;</span>

    <span style="color: #75715e">&lt;!-- PROXY: optional http proxy for access to the internet--&gt;</span>
    <span style="color: #f92672">&lt;PROXY&gt;</span>  <span style="color: #f92672">&lt;/PROXY&gt;</span>

    <span style="color: #75715e">&lt;!-- COMPILERS: compilers supported on this machine, comma seperated list, first is default --&gt;</span>
    <span style="color: #f92672">&lt;COMPILERS&gt;</span>intel,gnu<span style="color: #f92672">&lt;/COMPILERS&gt;</span>

    <span style="color: #75715e">&lt;!-- MPILIBS: mpilibs supported on this machine, comma seperated list,</span>
<span style="color: #75715e">	     first is default, mpi-serial is assumed and not required in this list--&gt;</span>
    <span style="color: #f92672">&lt;MPILIBS&gt;</span>openmpi<span style="color: #f92672">&lt;/MPILIBS&gt;</span>

    <span style="color: #75715e">&lt;!-- PROJECT: A project or account number used for batch jobs</span>
<span style="color: #75715e">         This value is used for directory names. If different from</span>
<span style="color: #75715e">         actual accounting project id, use CHARGE_ACCOUNT</span>
<span style="color: #75715e">	 can be overridden in environment or $HOME/.cime/config --&gt;</span>
    <span style="color: #75715e">&lt;!--PROJECT&gt;my_cesm_project_placeholder&lt;/PROJECT--&gt;</span>

    <span style="color: #75715e">&lt;!-- CHARGE_ACCOUNT: A project or account number used for batch jobs</span>
<span style="color: #75715e">	 This is the actual project used for cost accounting set in</span>
<span style="color: #75715e">         the batch script (ex. #PBS -A charge_account). Will default</span>
<span style="color: #75715e">         to PROJECT if not set.</span>
<span style="color: #75715e">	 can be overridden in environment or $HOME/.cime/config --&gt;</span>
    <span style="color: #75715e">&lt;!-- &lt;CHARGE_ACCOUNT&gt;$ENV{MY_SLURM_ACCOUNT}&lt;/CHARGE_ACCOUNT&gt; --&gt;</span>

    <span style="color: #75715e">&lt;!-- SAVE_TIMING_DIR: (Acme only) directory for archiving timing output --&gt;</span>
    <span style="color: #75715e">&lt;!-- SAVE_TIMING_DIR&gt; &lt;/SAVE_TIMING_DIR --&gt;</span>

    <span style="color: #75715e">&lt;!-- SAVE_TIMING_DIR_PROJECTS: (Acme only) projects whose jobs archive timing output --&gt;</span>
    <span style="color: #75715e">&lt;!-- SAVE_TIMING_DIR_PROJECTS&gt; &lt;/SAVE_TIMING_DIR_PROJECTS --&gt;</span>

    <span style="color: #75715e">&lt;!-- CIME_OUTPUT_ROOT: Base directory for case output,</span>
<span style="color: #75715e">	 the case/bld and case/run directories are written below here --&gt;</span>
    <span style="color: #f92672">&lt;CIME_OUTPUT_ROOT&gt;</span>$ENV{MY_CESM_ROOT}/output/$ENV{CESM_GROUP}<span style="color: #f92672">&lt;/CIME_OUTPUT_ROOT&gt;</span>

    <span style="color: #75715e">&lt;!-- DIN_LOC_ROOT: location of the inputdata data directory</span>
<span style="color: #75715e">	 inputdata is downloaded automatically on a case by case basis as</span>
<span style="color: #75715e">	 long as the user has write access to this directory.   We recommend that</span>
<span style="color: #75715e">	 all cime model users on a system share an inputdata directory</span>
<span style="color: #75715e">	 as it can be quite large --&gt;</span>
    <span style="color: #f92672">&lt;DIN_LOC_ROOT&gt;</span>$ENV{DIN_LOC_ROOT}<span style="color: #f92672">&lt;/DIN_LOC_ROOT&gt;</span>

    <span style="color: #75715e">&lt;!-- DIN_LOC_ROOT_CLMFORC: override of DIN_LOC_ROOT specific to CLM</span>
<span style="color: #75715e">	 forcing data --&gt;</span>
    <span style="color: #f92672">&lt;DIN_LOC_ROOT_CLMFORC&gt;</span>$ENV{MY_CESM_ROOT}/shared_lmwg<span style="color: #f92672">&lt;/DIN_LOC_ROOT_CLMFORC&gt;</span>

    <span style="color: #75715e">&lt;!-- DOUT_S_ROOT: root directory of short term archive files, short term</span>
<span style="color: #75715e">      archiving moves model output data out of the run directory, but</span>
<span style="color: #75715e">      keeps it on disk--&gt;</span>
    <span style="color: #f92672">&lt;DOUT_S_ROOT&gt;</span>$CIME_OUTPUT_ROOT/archive/$CASE<span style="color: #f92672">&lt;/DOUT_S_ROOT&gt;</span>

    <span style="color: #75715e">&lt;!-- BASELINE_ROOT:  Root directory for system test baseline files --&gt;</span>
    <span style="color: #f92672">&lt;BASELINE_ROOT&gt;</span>$ENV{MY_CESM_ROOT}/cesm_baselines<span style="color: #f92672">&lt;/BASELINE_ROOT&gt;</span>

    <span style="color: #75715e">&lt;!-- CCSM_CPRNC: location of the cprnc tool, compares model output in testing--&gt;</span>
    <span style="color: #f92672">&lt;CCSM_CPRNC&gt;</span>$ENV{MY_CESM_ROOT}/cesm2.1.3/cime/tools/cprnc/<span style="color: #f92672">&lt;/CCSM_CPRNC&gt;</span>

    <span style="color: #75715e">&lt;!-- GMAKE: gnu compatible make tool, default is &#39;gmake&#39; --&gt;</span>
    <span style="color: #f92672">&lt;GMAKE&gt;</span>gmake<span style="color: #f92672">&lt;/GMAKE&gt;</span>

    <span style="color: #75715e">&lt;!-- GMAKE_J: optional number of threads to pass to the gmake flag --&gt;</span>
    <span style="color: #f92672">&lt;GMAKE_J&gt;</span>8<span style="color: #f92672">&lt;/GMAKE_J&gt;</span>

    <span style="color: #75715e">&lt;!-- BATCH_SYSTEM: batch system used on this machine,</span>
<span style="color: #75715e">      supported values are: none, cobalt, lsf, pbs, slurm --&gt;</span>
    <span style="color: #f92672">&lt;BATCH_SYSTEM&gt;</span>slurm<span style="color: #f92672">&lt;/BATCH_SYSTEM&gt;</span>

    <span style="color: #75715e">&lt;!-- SUPPORTED_BY: contact information for support for this system</span>
<span style="color: #75715e">      this field is not used in code --&gt;</span>
    <span style="color: #f92672">&lt;SUPPORTED_BY&gt;</span>arcts-support@umich.edu<span style="color: #f92672">&lt;/SUPPORTED_BY&gt;</span>

    <span style="color: #75715e">&lt;!-- MAX_TASKS_PER_NODE: maximum number of threads*tasks per</span>
<span style="color: #75715e">	 shared memory node on this machine,</span>
<span style="color: #75715e">	 should always be &gt;= MAX_MPITASKS_PER_NODE --&gt;</span>
    <span style="color: #f92672">&lt;MAX_TASKS_PER_NODE&gt;</span>36<span style="color: #f92672">&lt;/MAX_TASKS_PER_NODE&gt;</span>

    <span style="color: #75715e">&lt;!-- MAX_MPITASKS_PER_NODE: number of physical PES per shared node on</span>
<span style="color: #75715e">	 this machine, in practice the MPI tasks per node will not exceed this value --&gt;</span>
    <span style="color: #f92672">&lt;MAX_MPITASKS_PER_NODE&gt;</span>36<span style="color: #f92672">&lt;/MAX_MPITASKS_PER_NODE&gt;</span>

    <span style="color: #75715e">&lt;!-- PROJECT_REQUIRED: Does this machine require a project to be specified to</span>
<span style="color: #75715e">	 the batch system?  See PROJECT above --&gt;</span>
    <span style="color: #f92672">&lt;PROJECT_REQUIRED&gt;</span>FALSE<span style="color: #f92672">&lt;/PROJECT_REQUIRED&gt;</span>

    <span style="color: #75715e">&lt;!-- mpirun: The mpi exec to start a job on this machine, supported values</span>
<span style="color: #75715e">	 are values listed in MPILIBS above, default and mpi-serial --&gt;</span>
    <span style="color: #f92672">&lt;mpirun</span> <span style="color: #a6e22e">mpilib=</span><span style="color: #e6db74">&quot;openmpi&quot;</span><span style="color: #f92672">&gt;</span>
      <span style="color: #75715e">&lt;!-- name of the exectuable used to launch mpi jobs --&gt;</span>
      <span style="color: #f92672">&lt;executable&gt;</span>mpiexec<span style="color: #f92672">&lt;/executable&gt;</span>
      <span style="color: #75715e">&lt;!-- arguments to the mpiexec command, the name attribute here is ignored--&gt;</span>
      <span style="color: #f92672">&lt;arguments&gt;</span>
	<span style="color: #f92672">&lt;arg</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;num_tasks&quot;</span><span style="color: #f92672">&gt;</span>-n {{ total_tasks }}<span style="color: #f92672">&lt;/arg&gt;</span>
      <span style="color: #f92672">&lt;/arguments&gt;</span>
    <span style="color: #f92672">&lt;/mpirun&gt;</span>
    <span style="color: #f92672">&lt;mpirun</span> <span style="color: #a6e22e">mpilib=</span><span style="color: #e6db74">&quot;mpi-serial&quot;</span><span style="color: #f92672">&gt;</span>
      <span style="color: #f92672">&lt;executable&gt;&lt;/executable&gt;</span>
    <span style="color: #f92672">&lt;/mpirun&gt;</span>
    <span style="color: #75715e">&lt;!-- module system: allowed module_system type values are:</span>
<span style="color: #75715e">	 module  http://www.tacc.utexas.edu/tacc-projects/mclay/lmod</span>
<span style="color: #75715e">	 soft http://www.mcs.anl.gov/hs/software/systems/softenv/softenv-intro.html</span>
<span style="color: #75715e">         none</span>
<span style="color: #75715e">      --&gt;</span>
    <span style="color: #f92672">&lt;module_system</span> <span style="color: #a6e22e">type=</span><span style="color: #e6db74">&quot;module&quot;</span> <span style="color: #a6e22e">allow_error=</span><span style="color: #e6db74">&quot;true&quot;</span><span style="color: #f92672">&gt;</span>
      <span style="color: #f92672">&lt;init_path</span> <span style="color: #a6e22e">lang=</span><span style="color: #e6db74">&quot;perl&quot;</span><span style="color: #f92672">&gt;</span>/sw/arcts/centos7/lmod/lmod/init/perl<span style="color: #f92672">&lt;/init_path&gt;</span>
      <span style="color: #f92672">&lt;init_path</span> <span style="color: #a6e22e">lang=</span><span style="color: #e6db74">&quot;python&quot;</span><span style="color: #f92672">&gt;</span>/sw/arcts/centos7/lmod/lmod/init/env_modules_python.py<span style="color: #f92672">&lt;/init_path&gt;</span>
      <span style="color: #f92672">&lt;init_path</span> <span style="color: #a6e22e">lang=</span><span style="color: #e6db74">&quot;csh&quot;</span><span style="color: #f92672">&gt;</span>/sw/arcts/centos7/lmod/lmod/init/csh<span style="color: #f92672">&lt;/init_path&gt;</span>
      <span style="color: #f92672">&lt;init_path</span> <span style="color: #a6e22e">lang=</span><span style="color: #e6db74">&quot;sh&quot;</span><span style="color: #f92672">&gt;</span>/sw/arcts/centos7/lmod/lmod/init/sh<span style="color: #f92672">&lt;/init_path&gt;</span>

      <span style="color: #f92672">&lt;cmd_path</span> <span style="color: #a6e22e">lang=</span><span style="color: #e6db74">&quot;perl&quot;</span><span style="color: #f92672">&gt;</span>/sw/arcts/centos7/lmod/lmod/libexec/lmod perl<span style="color: #f92672">&lt;/cmd_path&gt;</span>
      <span style="color: #f92672">&lt;cmd_path</span> <span style="color: #a6e22e">lang=</span><span style="color: #e6db74">&quot;python&quot;</span><span style="color: #f92672">&gt;</span>/sw/arcts/centos7/lmod/lmod/libexec/lmod python<span style="color: #f92672">&lt;/cmd_path&gt;</span>
      <span style="color: #f92672">&lt;cmd_path</span> <span style="color: #a6e22e">lang=</span><span style="color: #e6db74">&quot;sh&quot;</span><span style="color: #f92672">&gt;</span>module<span style="color: #f92672">&lt;/cmd_path&gt;</span>
      <span style="color: #f92672">&lt;cmd_path</span> <span style="color: #a6e22e">lang=</span><span style="color: #e6db74">&quot;csh&quot;</span><span style="color: #f92672">&gt;</span>module<span style="color: #f92672">&lt;/cmd_path&gt;</span>

      <span style="color: #f92672">&lt;modules</span> <span style="color: #a6e22e">compiler=</span><span style="color: #e6db74">&quot;gnu&quot;</span><span style="color: #f92672">&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;purge&quot;</span><span style="color: #f92672">&gt;&lt;/command&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>gcc/8.2.0<span style="color: #f92672">&lt;/command&gt;</span>
        <span style="color: #75715e">&lt;!-- &lt;command name=&quot;load&quot;&gt;openmpi/4.0.2&lt;/command&gt; --&gt;</span> <span style="color: #75715e">&lt;!-- Does not work on GL! --&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>openmpi/3.1.4<span style="color: #f92672">&lt;/command&gt;</span> <span style="color: #75715e">&lt;!-- Has bugs openmpi/3.1.4 but seems to work! --&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>cmake/3.13.2<span style="color: #f92672">&lt;/command&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>hdf5/1.8.21<span style="color: #f92672">&lt;/command&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>netcdf-c/4.6.2<span style="color: #f92672">&lt;/command&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>netcdf-fortran/4.4.5<span style="color: #f92672">&lt;/command&gt;</span>
      <span style="color: #f92672">&lt;/modules&gt;</span>
      <span style="color: #f92672">&lt;modules</span> <span style="color: #a6e22e">compiler=</span><span style="color: #e6db74">&quot;intel&quot;</span><span style="color: #f92672">&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;purge&quot;</span><span style="color: #f92672">&gt;&lt;/command&gt;</span>
        <span style="color: #75715e">&lt;!-- &lt;command name=&quot;load&quot;&gt;intel/19.1&lt;/command&gt; --&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>intel/18.0.5<span style="color: #f92672">&lt;/command&gt;</span>
        <span style="color: #75715e">&lt;!-- &lt;command name=&quot;load&quot;&gt;intel/14.0.2&lt;/command&gt; --&gt;</span>
        <span style="color: #75715e">&lt;!-- &lt;command name=&quot;load&quot;&gt;openmpi/4.0.2&lt;/command&gt; --&gt;</span> <span style="color: #75715e">&lt;!-- Does not work on GL! --&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>openmpi/3.1.4<span style="color: #f92672">&lt;/command&gt;</span> <span style="color: #75715e">&lt;!-- Has bugs openmpi/3.1.4 but seems to work! --&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>cmake/3.13.2<span style="color: #f92672">&lt;/command&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>hdf5/1.8.21<span style="color: #f92672">&lt;/command&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>netcdf-c/4.6.2<span style="color: #f92672">&lt;/command&gt;</span>
        <span style="color: #f92672">&lt;command</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;load&quot;</span><span style="color: #f92672">&gt;</span>netcdf-fortran/4.4.5<span style="color: #f92672">&lt;/command&gt;</span>
      <span style="color: #f92672">&lt;/modules&gt;</span>
    <span style="color: #f92672">&lt;/module_system&gt;</span>

    <span style="color: #75715e">&lt;!-- environment variables, a blank entry will unset a variable --&gt;</span>
    <span style="color: #f92672">&lt;environment_variables&gt;</span>
      <span style="color: #f92672">&lt;env</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;NETCDF_C_PATH&quot;</span><span style="color: #f92672">&gt;</span>$ENV{NCDIR}<span style="color: #f92672">&lt;/env&gt;</span>
      <span style="color: #f92672">&lt;env</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;NETCDF_FORTRAN_PATH&quot;</span><span style="color: #f92672">&gt;</span>$ENV{NFDIR}<span style="color: #f92672">&lt;/env&gt;</span>
      <span style="color: #f92672">&lt;env</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;LD_LIBRARY_PATH&quot;</span><span style="color: #f92672">&gt;</span>$ENV{LD_LIBRARY_PATH}<span style="color: #f92672">&lt;/env&gt;</span>
      <span style="color: #f92672">&lt;env</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;OMP_STACKSIZE&quot;</span><span style="color: #f92672">&gt;</span>256M<span style="color: #f92672">&lt;/env&gt;</span>
      <span style="color: #75715e">&lt;!--env name=&quot;MPI_TYPE_DEPTH&quot;&gt;16&lt;/env--&gt;</span>
    <span style="color: #f92672">&lt;/environment_variables&gt;</span>
    <span style="color: #75715e">&lt;!-- resource settings as defined in https://docs.python.org/2/library/resource.html --&gt;</span>
    <span style="color: #f92672">&lt;resource_limits&gt;</span>
      <span style="color: #f92672">&lt;resource</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;RLIMIT_STACK&quot;</span><span style="color: #f92672">&gt;</span>-1<span style="color: #f92672">&lt;/resource&gt;</span>
    <span style="color: #f92672">&lt;/resource_limits&gt;</span>
  <span style="color: #f92672">&lt;/machine&gt;</span>

<span style="color: #f92672">&lt;/config_machines&gt;</span>
</pre></div>

</pre>

</details>



## New CMake file:

<details>
<summary><code>~/.cime/greatlakes.cmake</code></summary>
  
  
<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">CFLAGS</span> <span style="color: #e6db74">&quot; -qno-opt-dynamic-align -fp-model precise -std=gnu99 -L$ENV{NC_ROOT}/lib -lnetcdf -L$ENV{NF_ROOT}/lib -lnetcdff&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">compile_threaded</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">CFLAGS</span> <span style="color: #e6db74">&quot; -qopenmp&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">NOT</span> <span style="color: #e6db74">DEBUG</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">CFLAGS</span> <span style="color: #e6db74">&quot; -O2 -debug minimal -xCORE-AVX2&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">DEBUG</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">CFLAGS</span> <span style="color: #e6db74">&quot; -O0 -g&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">CPPDEFS</span> <span style="color: #e6db74">&quot; -DFORTRANUNDERSCORE -DCPRINTEL&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">CXX_LDFLAGS</span> <span style="color: #e6db74">&quot; -cxxlib&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">CXX_LINKER</span> <span style="color: #e6db74">&quot;FORTRAN&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">FC_AUTO_R8</span> <span style="color: #e6db74">&quot;-r8&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">FFLAGS</span> <span style="color: #e6db74">&quot; -qno-opt-dynamic-align  -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source -L$ENV{NC_ROOT}/lib -lnetcdf -L$ENV{NF_ROOT}/lib -lnetcdff&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">compile_threaded</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">FFLAGS</span> <span style="color: #e6db74">&quot; -qopenmp&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">DEBUG</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">FFLAGS</span> <span style="color: #e6db74">&quot; -O0 -g -check uninit -check bounds -check pointers -fpe0 -check noarg_temp_created&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">NOT</span> <span style="color: #e6db74">DEBUG</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">FFLAGS</span> <span style="color: #e6db74">&quot; -O2 -debug minimal -xCORE-AVX2&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">FFLAGS_NOOPT</span> <span style="color: #e6db74">&quot;-O0&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">FIXEDFLAGS</span> <span style="color: #e6db74">&quot;-fixed&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">FREEFLAGS</span> <span style="color: #e6db74">&quot;-free&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">compile_threaded</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">LDFLAGS</span> <span style="color: #e6db74">&quot; -qopenmp&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">MPICC</span> <span style="color: #e6db74">&quot;mpicc&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">MPICXX</span> <span style="color: #e6db74">&quot;mpicxx&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">MPIFC</span> <span style="color: #e6db74">&quot;mpif90&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">SCC</span> <span style="color: #e6db74">&quot;icc&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">SCXX</span> <span style="color: #e6db74">&quot;icpc&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">SFC</span> <span style="color: #e6db74">&quot;ifort&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">NETCDF_C_PATH</span> <span style="color: #960050; background-color: #1e0010">$</span><span style="color: #e6db74">ENV{NETCDF_C_PATH}</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">NETCDF_FORTRAN_PATH</span> <span style="color: #960050; background-color: #1e0010">$</span><span style="color: #e6db74">ENV{NETCDF_FORTRAN_PATH}</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">MPILIB</span> <span style="color: #e6db74">STREQUAL</span> <span style="color: #e6db74">mpich</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">SLIBS</span> <span style="color: #e6db74">&quot; -mkl=cluster&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">MPILIB</span> <span style="color: #e6db74">STREQUAL</span> <span style="color: #e6db74">mpich2</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">SLIBS</span> <span style="color: #e6db74">&quot; -mkl=cluster&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">MPILIB</span> <span style="color: #e6db74">STREQUAL</span> <span style="color: #e6db74">mvapich</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">SLIBS</span> <span style="color: #e6db74">&quot; -mkl=cluster&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">MPILIB</span> <span style="color: #e6db74">STREQUAL</span> <span style="color: #e6db74">mvapich2</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">SLIBS</span> <span style="color: #e6db74">&quot; -mkl=cluster&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">MPILIB</span> <span style="color: #e6db74">STREQUAL</span> <span style="color: #e6db74">mpt</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">SLIBS</span> <span style="color: #e6db74">&quot; -mkl=cluster&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">MPILIB</span> <span style="color: #e6db74">STREQUAL</span> <span style="color: #e6db74">openmpi</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">SLIBS</span> <span style="color: #e6db74">&quot; -mkl=cluster&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">MPILIB</span> <span style="color: #e6db74">STREQUAL</span> <span style="color: #e6db74">impi</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">SLIBS</span> <span style="color: #e6db74">&quot; -mkl=cluster&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">if</span> <span style="color: #f8f8f2">(</span><span style="color: #e6db74">MPILIB</span> <span style="color: #e6db74">STREQUAL</span> <span style="color: #e6db74">mpi-serial</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">string(</span><span style="color: #e6db74">APPEND</span> <span style="color: #e6db74">SLIBS</span> <span style="color: #e6db74">&quot; -mkl&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">endif()</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">SUPPORTS_CXX</span> <span style="color: #e6db74">&quot;TRUE&quot;</span><span style="color: #f8f8f2">)</span>
<span style="color: #f8f8f2">set(</span><span style="color: #e6db74">HAS_F2008_CONTIGUOUS</span> <span style="color: #e6db74">&quot;FALSE&quot;</span><span style="color: #f8f8f2">)</span>
</pre></div>

</pre>
</details>

The main stumbling block here is that it relies on the environment variables `$NETCDF_C_PATH` and `$NETCDF_FORTRAN_PATH` which are set in the XML file above. Note that these are _distinct directories_. This will be important later.




# Dealing with an unresolved ESMF dependency:

If I follow my usual [case creation script](https://open-lab-notebook.glitch.me/posts/cesm/case_creation_script/), then I do the following

```
cd ${CASE_DIR} #set in the script above, or use your own
source bash.source
bash xml_change_helper.sh
```

which all succeed. However, when I run `./case.build` I get the following error message:

```
   Calling /home/owhughes/cesm_src/2022_05_05_FV3/components/cmeps/cime_config/buildnml
ERROR: ESMFMKFILE not found None
```

There is likely a more elegant way to fix this, but I fixed this by downloading the [ESMF 8.1.1 source code](https://earthsystemmodeling.org/download/) and building it using the following script

<details>
  <summary><code>build_esmf.sh</code></summary>
  
<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">module load intel/18.0.5
module load openmpi/3.1.4
<span style="color: #f8f8f2">export ESMF_LIB</span><span style="color: #f92672">=</span><span style="color: #e6db74">`</span><span style="color: #f8f8f2">pwd</span><span style="color: #e6db74">`</span>
<span style="color: #f8f8f2">export ESMF_CXX</span><span style="color: #f92672">=</span>mpicxx
<span style="color: #f8f8f2">export ESMF_COMM</span><span style="color: #f92672">=</span>openmpi
<span style="color: #f8f8f2">export ESMF_COMPILER</span><span style="color: #f92672">=</span>intel
<span style="color: #f8f8f2">export ESMF_F90</span><span style="color: #f92672">=</span>mpif90
make -j8
</pre></div>

</pre>
</details>
and run this script in the root directory of the ESMF source (which for me is `/home/owhughes/esmf/esmf-ESMF_8_1_1`).

Once this is built I run `find ~+ -name "esmf.mk"` (note: this uses a bash-specific idiom). For me this returns `/home/owhughes/esmf/esmf-ESMF_8_1_1/lib/libO/Linux.intel.64.openmpi.default/esmf.mk`.

Once I add `export ESMFMKFILE="/home/owhughes/esmf/esmf-ESMF_8_1_1/lib/libO/Linux.intel.64.openmpi.default/esmf.mk"` to my `${CASE_DIR}/bash.source` file, and run `source bash.source`, this resolves the error for this sectino.


## Fixing a bug in the FMS makefile.cesm

Once the previous modifications are made