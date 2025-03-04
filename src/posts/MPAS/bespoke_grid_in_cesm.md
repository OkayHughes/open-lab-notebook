---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Adding a variable resolution grid to CAM via CIME
  parent: MPAS tutorials
layout: layouts/post.njk
---

## Introduction
A recent version of [the Community Atmosphere Model](https://github.com/ESCOMP/CAM/tree/cam_development)
added limited support for the Model for Prediction Across Scales (MPAS) atmospheric dynamical core.
MPAS is a dynamical core with support for a non-hydrostatic equation set built in. It is based on a C-grid discretization on
Spherical Centroidal Voronoi Tesselation (SCVT) horizontal mesh. As such 
it is designed to support variable resolution grids when it is run in its own codebase.
The CIME infrastructure that makes creating new cases and component sets 
necessarily limits the number of horizontal grid spacings that you can use.

This post is designed to show you how to add a new variable resolution MPAS grid
to CIME. <span class="todo">I have used this for aquaplanet runs, but I have not tried AMIP runs _yet_.</span>

In order to run this you will regrettably need access to a working standalone version of the MPAS-A model
available [here](https://github.com/MPAS-Dev/MPAS-Model).
I am working on a containerized version that is easy to run on a laptop [here](https://open-lab-notebook.glitch.me/posts/MPAS/singularity_mpas_def/)
which is currently a work in progress.

## Step -1: install MPAS

For the time being, I have [instructions](https://open-lab-notebook.glitch.me/posts/installing-mpas/) on how I installed MPAS on the [Great Lakes Cluster](https://arc.umich.edu/greatlakes/)
located at the University of Michigan.

If you have access to NCAR's Cheyenne, then your life is _much_ easier.

In order to compile MPAS on Cheyenne as of 2022-04-11, you can use the following scripts:

<details>
  <summary><code>setup.mpas.sh</code></summary>
  

<!-- HTML generated using hilite.me --><div style="background: #ffffff; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">module unload netcdf
module load intel/19.1.1  mpt/2.22
module load netcdf-mpi/4.7.4 pnetcdf/1.12.1 pio/2.5.2
</pre></div>


  
</details>

and 
<details>
<summary><code>build.mpas.sh</code></summary>


<!-- HTML generated using hilite.me --><div style="background: #ffffff; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">make ifort <span style="color: #aa0000">CORE</span>=init_atmosphere <span style="color: #aa0000">PRECISION</span>=single <span style="color: #aa0000">USE_PIO2</span>=<span style="color: #00aaaa">true</span>
make clean <span style="color: #aa0000">CORE</span>=atmosphere
make ifort <span style="color: #aa0000">CORE</span>=atmosphere <span style="color: #aa0000">PRECISION</span>=single <span style="color: #aa0000">USE_PIO2</span>=<span style="color: #00aaaa">true</span>
</pre></div>


</details>

* Before you proceed, run `source ${SOURCE_TO_SCRIPT}/setup.mpas.sh`.
* Download the MPAS code mentioned above. 
* Change directories into the root of the repository.
* Run the commands in order listed in `build.mpas.sh`.


## Step 0: generating the horizontal grid
Follow the instructions in my [other post](https://open-lab-notebook.glitch.me/posts/MPAS/made_to_measure_mpas/).

At this point I assume that you have a folder referred to by the variable `${GRID_DIR}`, and that
your grid has a unique prefix referred to in the variable `${GRID_PREFIX}`. This
prefix needs to uniquely identify your grid files so that they don't overlap with other MPAS files
in `${GRID_DIR}`.

In these instructions I will be using my particular use case as an example.
On Cheyenne, `GRID_DIR="${HOME}/grids/${GRID_PREFIX}/"` and `GRID_PREFIX="x4.92067"` where `x4` refers
to a 4x grid refinement in a band near the equator and the resulting grid has `92067` horizontal cells.
I'm going to call this grid `mpasa120-30` because on a full-radius grid it has a maximum grid spacing
of 120km and a minimum grid spacing of 30km.



**I make the assumption that you have generated the following files:**

* `${GRID_DIR}/${GRID_PREFIX}.grid.nc` contains a 2d representation of your MPAS grid connectivity.
* Several files `${GRID_DIR}/${GRID_PREFIX}.graph.info.part.${NPROC}` where `${NPROC}` includes
any number of MPI processes with which you want to run an MPAS model. It should probably be a multiple of the 
number of physical cores in a node within your cluster (or threads if your system has [HT](https://en.wikipedia.org/wiki/Hyper-threading), 
but I've had mixed success with this).
* `${GRID_DIR}/${GRID_PREFIX}.esmf.coupling.nc` which will be needed by the coupler within CAM.


## Step 1: Generating a 3D grid with metric terms

You will need to create a case directory, which I typically pattern off of [this example](https://www2.mmm.ucar.edu/projects/mpas/test_cases/v7.0/jw_baroclinic_wave.tar.gz)
There are two relevant lines in the namelist `namelist.init_atmosphere` that you will need to change: `config_nvertlevels = 26` and `config_init_case = {CASE_NUMBER}`.
`config_nvertlevels` is slightly confusing, as for a CAM configuration that's listed has having 30 levels, `config_nvertlevels` should be set to 32.

Specifying topography requires modifying source code. If the root of your MPAS installation is `${MPAS_SRC}`, then 
the file `src/core_init_atm/mpas_init_atm_cases.F`. I typically modify the DCMIP2008 mountain wave test case, which has multiple topographic smoothing profiles. 
I typically modify this test case, which is `config_init_case = 6`, and the subroutine `init_atm_case_mtn_wave` within `mpas_init_atm_cases.F`.

* The nature of the hybrid coordinates is set between lines 2139-2164. Setting `ah(k) = 0` defines pure terrain-following coordinates. 
I typically uncomment the line `ah(k) = 1.-cos(.5*pii*(k-1)*dz/zt)**6` if I have significant topography.
This loop is where you can define constant-height positions, e.g. by creating a local variable `real (kind=RKIND), dimension(nVertLevels+1) :: heightpos = (/ ... /)` at the start of the subroutine, 
then doing `zc(k) = heightpos(k)`. These should correspond to desired interface level positions in meters, e.g. derived from CAM 
* Around line 2212, the variable `hx` sets the topography. 
* Lines 2244-2275 are where metric terms are defined, but they use the `ah` and `zc` terms you modified earlier.



```
ln -s ${GRID_DIR}/${GRID_PREFIX}.grid.nc ${MPAS_CASE_DIR} 
ln -s ${GRID_DIR}/$GRID_PREFIX}.graph.info.part.${NPROC} ${MPAS_CASE_DIR}
```

Continue until you call `mpirun -n ${NPROC} ./init_atmosphere_model` which generates a NetCDF file 
that contains a dimension called `nVertLevels.` 
I'm going to assume that this file is moved to `${GRID_DIR}/${GRID_PREFIX}.init.nc`.

### Vital considerations:
As of 2022-04-11 the CAM MPAS implementation does not understand how to generate 3d metric terms for
MPAS. My understanding is that it knows how to correctly overwrite prognostic fields like edge wind flux
components. However, because MPAS uses height as a vertical coordinate, generation of
terrain following coordinates is rather involved. 
As such, <span class="todo">_any topography that you intend to include in your CAM run must be in
  your `${GRID_DIR}/${GRID_PREFIX}.init.nc`_</span>
  
Similarly <span class="todo">_your vertical level number and location will be set by
creating this file. Ensure it matches the CAM vertical level configuration that you want to use._
</span>






## Modifying CIME!


### Modifications to `${CAM_ROOT}/bld/namelist_files/namelist_defaults_cam.xml`


#### analytic initialization grid files
In this file there are lines reading something like 
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;ncdata</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120&quot;</span> <span style="color: #a6e22e">nlev=</span><span style="color: #e6db74">&quot;32&quot;</span> <span style="color: #a6e22e">analytic_ic=</span><span style="color: #e6db74">&quot;1&quot;</span> <span style="color: #a6e22e">phys=</span><span style="color: #e6db74">&quot;cam_dev&quot;</span> <span style="color: #f92672">&gt;</span>atm/cam/inic/mpas/mpasa120_L32_topo_coords_c201022.nc<span style="color: #f92672">&lt;/ncdata&gt;</span>
</pre></div>


Here `mpasa120` refers to an approximately `$$1^\circ $$` grid with a nominal grid spacing of 120km. 
These files are used in the case that you are starting from analytic initial conditions, such as 
the [UMJS Moist Baroclinic Wave](https://www.cesm.ucar.edu/models/simpler-models-indev/fkessler/index.html)
which can be used to spin up aquaplanets. The purpose of these files is
to provide vertical levels and associated metric terms for such a run. 

I make use of the file that I generated using the standalone version of MPAS, and make the following definition


<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;ncdata</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120-30&quot;</span> <span style="color: #a6e22e">nlev=</span><span style="color: #e6db74">&quot;32&quot;</span> <span style="color: #a6e22e">analytic_ic=</span><span style="color: #e6db74">&quot;1&quot;</span> <span style="color: #f92672">&gt;</span>/glade/u/home/owhughes/grids/x4.92067/x4.92067.init.nc<span style="color: #f92672">&lt;/ncdata&gt;</span>
</pre></div>


#### problem: `bnd_topo` grid file
The definition 
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"> <span style="color: #f92672">&lt;bnd_topo</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120&quot;</span> <span style="color: #f92672">&gt;</span>atm/cam/topo/mpas/mpas_120_nc3000_Co060_Fi001_MulG_PF_Nsw042_c200921.nc<span style="color: #f92672">&lt;/bnd_topo&gt;</span>
</pre></div>

sets the location of a topography file. <span class="todo"> I don't know how to generate
this file yet.</span> 


#### `drydep_srf_file`

The definition
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;drydep_srf_file</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120&quot;</span><span style="color: #f92672">&gt;</span>atm/cam/chem/trop_mam/atmsrf_mpasa120_c090720.nc<span style="color: #f92672">&lt;/drydep_srf_file&gt;</span>
</pre></div>

defines land use fields that are required when doing an aquaplanet run for some reason.

For the sake of my current runs I create a dummy file which has the correct dimensions but all
fields are identically 0. Assuming that you have access to the `xarray` and `numpy` python packages (
e.g. by installing [miniconda](https://docs.conda.io/en/latest/miniconda.html) and running `conda install xarray`)
then you can use the following python script:

<details>
  <summary><code>create_srf.py</code></summary>
  
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">import</span> <span style="color: #f8f8f2">xarray</span> <span style="color: #66d9ef">as</span> <span style="color: #f8f8f2">xr</span>
<span style="color: #f92672">import</span> <span style="color: #f8f8f2">numpy</span> <span style="color: #66d9ef">as</span> <span style="color: #f8f8f2">np</span>

<span style="color: #f8f8f2">ncol</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">92067</span> <span style="color: #75715e"># modify this to match your grid!</span>
<span style="color: #f8f8f2">nclass</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">11</span>
<span style="color: #f8f8f2">nmonth</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">12</span>
<span style="color: #f8f8f2">fraction_landuse</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros((nclass,</span> <span style="color: #f8f8f2">ncol))</span>
<span style="color: #f8f8f2">soilw</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">np</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">zeros((nmonth,ncol))</span>
<span style="color: #f8f8f2">ds</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">xr</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">Dataset(</span>
    <span style="color: #f8f8f2">{</span>
       <span style="color: #e6db74">&quot;fraction_landuse&quot;</span><span style="color: #f8f8f2">:</span> <span style="color: #f8f8f2">([</span><span style="color: #e6db74">&quot;class&quot;</span><span style="color: #f8f8f2">,</span> <span style="color: #e6db74">&quot;ncol&quot;</span><span style="color: #f8f8f2">],</span> <span style="color: #f8f8f2">fraction_landuse),</span>
        <span style="color: #e6db74">&quot;soilw&quot;</span><span style="color: #f8f8f2">:</span> <span style="color: #f8f8f2">([</span><span style="color: #e6db74">&quot;month&quot;</span><span style="color: #f8f8f2">,</span> <span style="color: #e6db74">&quot;ncol&quot;</span><span style="color: #f8f8f2">],</span> <span style="color: #f8f8f2">soilw),</span>
    <span style="color: #f8f8f2">}</span>
 <span style="color: #f8f8f2">)</span>


<span style="color: #f8f8f2">ds</span><span style="color: #f92672">.</span><span style="color: #f8f8f2">to_netcdf(path</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;atmsrf_mpasa120-30.nc&quot;</span><span style="color: #f8f8f2">)</span>
</pre></div>



  
</details>


I then add the following definition to the xml file:

<!-- HTML generated using hilite.me --><div style="background: #172822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;drydep_srf_file</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120-30&quot;</span><span style="color: #f92672">&gt;</span>/glade/u/home/owhughes/grids/stub_data/atmsrf_mpasa120-30.nc<span style="color: #f92672">&lt;/drydep_srf_file&gt;</span>
</pre></div>


(note that I have put this in a separate directory from `${GRID_DIR}`).

#### Default timestep and diffusion:

You will find a line similar to 

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;mpas_dt</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120&quot;</span>     <span style="color: #f92672">&gt;</span>  900.0D0 <span style="color: #f92672">&lt;/mpas_dt&gt;</span>
</pre></div>

This sets the dynamics timestep for the MPAS dynamical core. <span class="todo">
You will need to set `ATM_NCPL` using `./xmlchange` so that the total physics timestep
(i.e. `86400/ATM_NCPL`) is an integer multiple of `mpas_dt`. Otherwise CAM will throw a
runtime error right at the beginning of the run.</span>

This time step is chosen to obey numerical stability conditions (namely the [CFL](https://en.wikipedia.org/wiki/Courant%E2%80%93Friedrichs%E2%80%93Lewy_condition) condition).
For practical purposes, `900.0` seconds is sufficient for a `$$1^\circ $$` grid. When you halve the 
horizontal grid spacing, you must also halve the time step. Accordingly, for a grid with
minimum grid spacing `$$\frac{1}{4}^\circ $$`,
a timestep of 200 seconds is sufficient. I thus add the line

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;mpas_dt</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120-30&quot;</span>     <span style="color: #f92672">&gt;</span>  200.0D0 <span style="color: #f92672">&lt;/mpas_dt&gt;</span>
</pre></div>


MPAS's default diffusion scheme requires only one parameter 
which is set via a line like 
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;mpas_len_disp</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120&quot;</span><span style="color: #f92672">&gt;</span>120000.0D0<span style="color: #f92672">&lt;/mpas_len_disp&gt;</span>
</pre></div>


This value is set to the minimum grid spacing in meters, and thus we add

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;mpas_len_disp</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120-30&quot;</span><span style="color: #f92672">&gt;</span>30000.0D0<span style="color: #f92672">&lt;/mpas_len_disp&gt;</span>
</pre></div>


#### Block decomposition files:

You will find a line similar to
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;mpas_block_decomp_file_prefix</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120&quot;</span><span style="color: #f92672">&gt;</span>atm/cam/inic/mpas/mpasa120.graph.info.part.<span style="color: #f92672">&lt;/mpas_block_decomp_file_prefix&gt;</span>
</pre></div>


Here we leverage the processor decompositions we created when we generated our grid (mind you,
if you want to change the number of processors you're using for your run, you must ensure that
you have a suitable file in your `${GRID_DIR}` directory.) I thus add the line:

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="background:none;margin: 0; line-height: 125%"><span style="color: #f92672">&lt;mpas_block_decomp_file_prefix</span> <span style="color: #a6e22e">hgrid=</span><span style="color: #e6db74">&quot;mpasa120-30&quot;</span><span style="color: #f92672">&gt;</span>glade/u/home/owhughes/grids/x4.92067/x4.92067.graph.info.part.<span style="color: #f92672">&lt;/mpas_block_decomp_file_prefix&gt;</span>
</pre></div>




### Modifications to `${CAM_ROOT}/cime/config/cesm/config_grids.xml`
Note we have changed xml files
#### Defining a grid alias

In this file you will find a snippet of text similar to

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">    <span style="color: #f92672">&lt;model_grid</span> <span style="color: #a6e22e">alias=</span><span style="color: #e6db74">&quot;mpasa120_mpasa120&quot;</span> <span style="color: #a6e22e">not_compset=</span><span style="color: #e6db74">&quot;_POP&quot;</span><span style="color: #f92672">&gt;</span>
<span style="color: #f92672">&lt;grid</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;atm&quot;</span><span style="color: #f92672">&gt;</span>mpasa120<span style="color: #f92672">&lt;/grid&gt;</span>
<span style="color: #f92672">&lt;grid</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;lnd&quot;</span><span style="color: #f92672">&gt;</span>mpasa120<span style="color: #f92672">&lt;/grid&gt;</span>
<span style="color: #f92672">&lt;grid</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;ocnice&quot;</span><span style="color: #f92672">&gt;</span>mpasa120<span style="color: #f92672">&lt;/grid&gt;</span>
<span style="color: #f92672">&lt;mask&gt;</span>gx1v7<span style="color: #f92672">&lt;/mask&gt;</span>
<span style="color: #f92672">&lt;/model_grid&gt;</span>
</pre></div>


This defines the grids on which different components are defined. So far I have only
run aquaplanet simulations which are fairly robust to grid changes. The following definitions
work for running aquaplanet configurations but may break if you try to run AMIP.
<span class="todo">Test whether this is true lol.</span>
I add the following lines for my custom grid:

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #f92672">&lt;model_grid</span> <span style="color: #a6e22e">alias=</span><span style="color: #e6db74">&quot;mpasa120-30_mpasa120-30&quot;</span> <span style="color: #a6e22e">not_compset=</span><span style="color: #e6db74">&quot;_POP&quot;</span><span style="color: #f92672">&gt;</span>
  <span style="color: #f92672">&lt;grid</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;atm&quot;</span><span style="color: #f92672">&gt;</span>mpasa120-30<span style="color: #f92672">&lt;/grid&gt;</span>
  <span style="color: #f92672">&lt;grid</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;lnd&quot;</span><span style="color: #f92672">&gt;</span>mpasa120-30<span style="color: #f92672">&lt;/grid&gt;</span>
  <span style="color: #f92672">&lt;grid</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;ocnice&quot;</span><span style="color: #f92672">&gt;</span>mpasa120-30<span style="color: #f92672">&lt;/grid&gt;</span>
  <span style="color: #f92672">&lt;mask&gt;</span>gx1v7<span style="color: #f92672">&lt;/mask&gt;</span>
<span style="color: #f92672">&lt;/model_grid&gt;</span>
</pre></div>


This will allow us to do something like the following when we're creating a new case:

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #66d9ef">${</span><span style="color: #f8f8f2">SRC_DIR</span><span style="color: #66d9ef">}</span>/cime/scripts/create_newcase --compset <span style="color: #e6db74">&quot;${COMPSET}&quot;</span> --res <span style="color: #e6db74">&quot;mpasa120-30_mpasa120-30&quot;</span> --case <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">CASE_DIR</span><span style="color: #66d9ef">}</span>/<span style="color: #66d9ef">${</span><span style="color: #f8f8f2">CASE_NAME</span><span style="color: #66d9ef">}</span> --run-unsupported --project <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">PROJECT</span><span style="color: #66d9ef">}</span> --pecount <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">NPROCS</span><span style="color: #66d9ef">}</span>
</pre></div>


which uses the alias we set in the xml snippet above.

#### Creating a grid specification
We find a snippet of text like


<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #f92672">&lt;domain</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;mpasa120&quot;</span><span style="color: #f92672">&gt;</span>
  <span style="color: #f92672">&lt;nx&gt;</span>40962<span style="color: #f92672">&lt;/nx&gt;</span> <span style="color: #f92672">&lt;ny&gt;</span>1<span style="color: #f92672">&lt;/ny&gt;</span>
  <span style="color: #f92672">&lt;mesh</span> <span style="color: #a6e22e">driver=</span><span style="color: #e6db74">&quot;nuopc&quot;</span><span style="color: #f92672">&gt;</span>$DIN_LOC_ROOT/share/meshes/mpasa120z32_ESMFmesh_cdf5_c20210120.nc<span style="color: #f92672">&lt;/mesh&gt;</span>
  <span style="color: #f92672">&lt;desc&gt;</span>MPAS-A 120-km quasi-uniform mesh:<span style="color: #f92672">&lt;/desc&gt;</span>
<span style="color: #f92672">&lt;/domain&gt;</span>
</pre></div>


The `mesh` specification is what will force us to use the `${GRID_PREFIX}.esmf.coupling.nc` that we 
created above. Because MPAS is an unstructured grid, the only dimension you 
need to specify is the `nx` tag, which contains the number of columns. In my case I add
the following text:

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #f92672">&lt;domain</span> <span style="color: #a6e22e">name=</span><span style="color: #e6db74">&quot;mpasa120-30&quot;</span><span style="color: #f92672">&gt;</span>
  <span style="color: #f92672">&lt;nx&gt;</span>92067<span style="color: #f92672">&lt;/nx&gt;</span> <span style="color: #f92672">&lt;ny&gt;</span>1<span style="color: #f92672">&lt;/ny&gt;</span>
  <span style="color: #f92672">&lt;mesh</span> <span style="color: #a6e22e">driver=</span><span style="color: #e6db74">&quot;nuopc&quot;</span><span style="color: #f92672">&gt;</span>/glade/u/home/owhughes/grids/x4.92067/x4.92067.esmf.coupling.nc<span style="color: #f92672">&lt;/mesh&gt;</span>
  <span style="color: #f92672">&lt;desc&gt;</span>MPAS-A 120km-30km variable resolution grid:<span style="color: #f92672">&lt;/desc&gt;</span>
<span style="color: #f92672">&lt;/domain&gt;</span>
</pre></div>



## Step 4 creating and running a case
The following process was used to create, build, and run an aquaplanet configuration in CAM on 2022/04/11.
I use the [defensive bash](https://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/) 
scripting style to create my case in a repeatable way.

<details>
<summary><code>create_case.sh</code></summary>

  <!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #f8f8f2">export CESMDATAROOT</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$SCRATCH</span>/CESM_INPUT
<span style="color: #f8f8f2">readonly CESM_PREFIX</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;CAM_Jan22_var_res&quot;</span>
<span style="color: #f8f8f2">readonly COMPSET</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;2000_CAM40_SLND_SICE_DOCN%AQP1_SROF_SGLC_SWAV&quot;</span>
<span style="color: #f8f8f2">readonly GRID_NAME</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;mpasa120-30_mpasa120-30&quot;</span>
<span style="color: #f8f8f2">readonly GROUP_NAME</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;589_final_project&quot;</span>
<span style="color: #f8f8f2">readonly CASE_ID</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;AQP_spinup&quot;</span>
<span style="color: #f8f8f2">readonly PROJECT</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;UMIC0087&quot;</span>
<span style="color: #f8f8f2">readonly NPROCS</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;288&quot;</span>

<span style="color: #75715e"># =================</span>
<span style="color: #f8f8f2">readonly CASE_DIR</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${HOME}/CESM_CASE_DIRS/${CESM_PREFIX}_CASES/${CESM_PREFIX}/${GROUP_NAME}&quot;</span>
<span style="color: #f8f8f2">readonly SRC_DIR</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${HOME}/CESM_SRC_DIRS/${CESM_PREFIX}&quot;</span>
<span style="color: #f8f8f2">readonly CASE_NAME</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${CESM_PREFIX}.${GRID_NAME}.${COMPSET}.${GROUP_NAME}.${CASE_ID}&quot;</span>
<span style="color: #f8f8f2">readonly BUILD_ROOT</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;/glade/scratch/${USER}/$CASE_NAME&quot;</span>
<span style="color: #75715e"># =================</span>


change_cesm<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local cesm_prefix</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>
    rm <span style="color: #e6db74">&quot;${HOME}/cesm_src&quot;</span>
    rm <span style="color: #e6db74">&quot;${HOME}/cesm_cases&quot;</span>
    <span style="color: #f8f8f2">local src_dir</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${HOME}/CESM_SRC_DIRS/$cesm_prefix/&quot;</span>
    <span style="color: #66d9ef">if </span>is_dir <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">src_dir</span><span style="color: #66d9ef">}</span>; <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        </span>ln -s <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">src_dir</span><span style="color: #66d9ef">}</span> <span style="color: #e6db74">&quot;${HOME}/cesm_src&quot;</span>
    <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">echo</span> <span style="color: #e6db74">&quot;${src_dir} does not exist!&quot;</span>
        <span style="color: #f8f8f2">exit</span>
<span style="color: #f8f8f2">    </span><span style="color: #66d9ef">fi</span>
<span style="color: #66d9ef">    </span><span style="color: #f8f8f2">local case_dir</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;${HOME}/CESM_CASE_DIRS/${cesm_prefix}_CASES/&quot;</span>
    <span style="color: #66d9ef">if </span>is_dir <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">case_dir</span><span style="color: #66d9ef">}</span>; <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        </span>ln -s <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">case_dir</span><span style="color: #66d9ef">}</span> <span style="color: #e6db74">&quot;${HOME}/cesm_cases&quot;</span>
    <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">echo</span> <span style="color: #e6db74">&quot;${case_dir} does not exist!&quot;</span>
        <span style="color: #f8f8f2">exit</span>
<span style="color: #f8f8f2">    </span><span style="color: #66d9ef">fi</span>
    
<span style="color: #f92672">}</span>

handle_case_exists<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local abs_case_dir</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF</span>
<span style="color: #e6db74">Case directory </span>
<span style="color: #e6db74">${abs_case_dir} </span>
<span style="color: #e6db74">already exists! </span>

<span style="color: #e6db74">Cowardly refusing to overwrite it :(</span>

<span style="color: #e6db74">EOF</span>
    <span style="color: #f8f8f2">exit </span>1

<span style="color: #f92672">}</span>

create_case<span style="color: #f92672">(){</span>
    is_dir <span style="color: #e6db74">&quot;${CASE_DIR}/${CASE_NAME}&quot;</span> <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> handle_case_exists <span style="color: #e6db74">&quot;${CASE_DIR}/${CASE_NAME}&quot;</span>
    yes r | <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">SRC_DIR</span><span style="color: #66d9ef">}</span>/cime/scripts/create_newcase --compset <span style="color: #e6db74">&quot;${COMPSET}&quot;</span> --res <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">GRID_NAME</span><span style="color: #66d9ef">}</span> --case <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">CASE_DIR</span><span style="color: #66d9ef">}</span>/<span style="color: #66d9ef">${</span><span style="color: #f8f8f2">CASE_NAME</span><span style="color: #66d9ef">}</span> --run-unsupported --project <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">PROJECT</span><span style="color: #66d9ef">}</span> --pecount <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">NPROCS</span><span style="color: #66d9ef">}</span>
<span style="color: #f92672">}</span>

create_xml_config_helper<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/xml_config_helper.sh&quot;</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF &gt; $config_script</span>

<span style="color: #e6db74"># ------------------</span>

<span style="color: #e6db74">readonly DEBUG=FALSE</span>

<span style="color: #e6db74"># ------------------</span>
<span style="color: #e6db74"># set this to true if you want an archive directory</span>

<span style="color: #e6db74">readonly DOUT_S=FALSE</span>

<span style="color: #e6db74">#-------------------</span>
<span style="color: #e6db74"># valid options for this value are:</span>
<span style="color: #e6db74">#  nsteps, nseconds, nminutes, nhours, ndays, nmonths, nyears</span>

<span style="color: #e6db74">readonly STOP_OPTION=nmonths</span>

<span style="color: #e6db74"># ------------------</span>

<span style="color: #e6db74">readonly STOP_N=24</span>


<span style="color: #e6db74">readonly ATM_NCPL=288</span>

<span style="color: #e6db74"># ------------------</span>
<span style="color: #e6db74"># Set the frequency at which files for restarting the model (e.g. in the </span>
<span style="color: #e6db74"># case of a blowup) are written. If TRUE, make sure to set REST_N</span>

<span style="color: #e6db74">readonly REST_OPTION=nmonths</span>
<span style="color: #e6db74">readonly REST_N=1</span>

<span style="color: #e6db74"># ====================</span>
<span style="color: #e6db74"># CAM build flag (note: this is quite finicky and causes compiler errors if done wrong)</span>

<span style="color: #e6db74">readonly CAM_CONFIG_OPTS=&quot;--phys cam4 --aquaplanet --analytic_ic --nlev=30&quot;</span>

<span style="color: #e6db74"># --------------------</span>
<span style="color: #e6db74"># Maximum runtime:</span>

<span style="color: #e6db74">readonly HOURS=11</span>
<span style="color: #e6db74">readonly MINUTES=50</span>
<span style="color: #e6db74">readonly SECONDS=00</span>

<span style="color: #e6db74"># --------------------</span>

<span style="color: #e6db74">main() {</span>
<span style="color: #e6db74">    ./xmlchange DEBUG=\${DEBUG},DOUT_S=\${DOUT_S},STOP_OPTION=\${STOP_OPTION},STOP_N=\${STOP_N},REST_OPTION=\${REST_OPTION},REST_N=\${REST_N},ATM_NCPL=\${ATM_NCPL} \</span>
<span style="color: #e6db74">        &amp;&amp; ./xmlchange --file env_build.xml --id CAM_CONFIG_OPTS --val &quot;\${CAM_CONFIG_OPTS}&quot; \</span>
<span style="color: #e6db74">        &amp;&amp; ./xmlquery CAM_CONFIG_OPTS \</span>
<span style="color: #e6db74">        &amp;&amp; ./xmlchange JOB_WALLCLOCK_TIME=\${HOURS}:\${MINUTES}:\${SECONDS} \</span>
<span style="color: #e6db74">        &amp;&amp; ./case.setup</span>

<span style="color: #e6db74">}</span>


<span style="color: #e6db74">main</span>
<span style="color: #e6db74">EOF</span>
<span style="color: #f92672">}</span>

create_user_nl_cam<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/user_nl_cam&quot;</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF &gt; $config_script</span>
<span style="color: #e6db74">    ncdata  = &#39;/glade/u/home/owhughes/grids/x4.92067/x4.92067.init.deep.nc&#39;</span>
<span style="color: #e6db74">    mpas_block_decomp_file_prefix = &quot;/glade/u/home/owhughes/grids/x4.92067/x4.92067.graph.info.part.&quot;</span>
<span style="color: #e6db74">    drydep_srf_file=&quot;/glade/u/home/owhughes/grids/stub_data/atmsrf_mpasa120-30.nc&quot;</span>
<span style="color: #e6db74">    mpas_dt = 100.0</span>
<span style="color: #e6db74">    omega   = 0.00014584 </span>
<span style="color: #e6db74">    rearth  = 3185500.0</span>
<span style="color: #e6db74">    mpas_len_disp = 15000</span>
<span style="color: #e6db74">    analytic_ic_type = &#39;moist_baroclinic_wave_dcmip2016&#39;</span>
<span style="color: #e6db74">    empty_htapes     = .TRUE.</span>
<span style="color: #e6db74">    NDENS            = 2,2</span>
<span style="color: #e6db74">    fincl1           = &#39;SST:A&#39;,&#39;PHIS:A&#39;,&#39;PS:A&#39;,&#39;T:A&#39;,&#39;U:A&#39;,&#39;V:A&#39;,&#39;OMEGA:A&#39;,&#39;Q:A&#39;,&#39;ATMEINT:A&#39;,&#39;CLDICE:A&#39;,&#39;CLDLIQ:A&#39;,&#39;CLOUD:A&#39;,&#39;CLDTOT:A&#39;,&#39;PRECL:A&#39;,&#39;PRECC:A&#39;,&#39;PRECT:A&#39;,&#39;TMQ:A&#39;,&#39;TMCLDICE:A&#39;,&#39;TMCLDLIQ:A&#39;,&#39;SHFLX:A&#39;,&#39;LHFLX:A&#39;,&#39;QFLX:A&#39;,&#39;RELHUM:A&#39;,&#39;FLUT:A&#39;,&#39;U200:A&#39;,&#39;V200:A&#39;</span>
<span style="color: #e6db74">    fincl2           = &#39;PS:I&#39;,&#39;SHFLX:I&#39;,&#39;LHFLX:I&#39;,&#39;FLUT:I&#39;,&#39;TMQ:I&#39;,&#39;CLDTOT:I&#39;,&#39;PRECC:I&#39;,&#39;PRECT:I&#39;,&#39;U200:I&#39;,&#39;V200:I&#39;</span>
<span style="color: #e6db74">    MFILT            = 280, 721</span>
<span style="color: #e6db74">    NHTFRQ           = -720, -24</span>
<span style="color: #e6db74">    inithist         = &#39;ENDOFRUN&#39;</span>

<span style="color: #e6db74">EOF</span>

<span style="color: #f92672">}</span>

create_preview_namelists_helper<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/preview_namelists_helper.sh&quot;</span>
    cat <span style="color: #e6db74">&lt;&lt; EOF &gt; $config_script</span>
<span style="color: #e6db74">./preview_namelists &gt; preview_namelists.log 2&gt; preview_namelists.err </span>
<span style="color: #e6db74">EOF</span>
<span style="color: #f92672">}</span>

create_case_build_helper<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local config_script</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$CASE_DIR/${CASE_NAME}/case_build_helper.sh&quot;</span> 
    <span style="color: #f8f8f2">echo</span> <span style="color: #e6db74">&quot;qcmd -A ${PROJECT} -- ${CASE_DIR}/${CASE_NAME}/case.build&quot;</span> &gt; <span style="color: #f8f8f2">$config_script</span>
<span style="color: #f92672">}</span>




main<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    change_cesm <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">CESM_PREFIX</span><span style="color: #66d9ef">}</span>
    create_case <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> create_xml_config_helper <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> create_user_nl_cam <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> create_preview_namelists_helper <span style="color: #ae81ff">\</span>
        <span style="color: #f92672">&amp;&amp;</span> create_case_build_helper
    
<span style="color: #f92672">}</span>


<span style="color: #75715e"># ============================================================================</span>
<span style="color: #75715e"># begin namelist</span>
<span style="color: #75715e"># ============================================================================</span>

<span style="color: #75715e"># ===========================================================================</span>


<span style="color: #75715e"># ============================================================================</span>
<span style="color: #75715e"># begin boilerplate </span>
<span style="color: #75715e"># ============================================================================</span>

<span style="color: #f8f8f2">readonly PROGNAME</span><span style="color: #f92672">=</span><span style="color: #66d9ef">$(</span>basename <span style="color: #f8f8f2">$0</span><span style="color: #66d9ef">)</span>
<span style="color: #f8f8f2">readonly PROGDIR</span><span style="color: #f92672">=</span><span style="color: #66d9ef">$(</span>readlink -m <span style="color: #66d9ef">$(</span>dirname <span style="color: #f8f8f2">$0</span><span style="color: #66d9ef">))</span>
<span style="color: #f8f8f2">readonly ARGS</span><span style="color: #f92672">=</span><span style="color: #e6db74">&quot;$@&quot;</span>

is_empty<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local var</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> -z <span style="color: #f8f8f2">$var</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>

is_not_empty<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local var</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> -n <span style="color: #f8f8f2">$var</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>

is_file<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local file</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> -f <span style="color: #f8f8f2">$file</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>

is_link<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local var</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> <span style="color: #e6db74">`</span><span style="color: #f8f8f2">test</span> -L <span style="color: #f8f8f2">$1</span><span style="color: #e6db74">`</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>


is_dir<span style="color: #f92672">()</span> <span style="color: #f92672">{</span>
    <span style="color: #f8f8f2">local dir</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">$1</span>

    <span style="color: #f92672">[[</span> -d <span style="color: #f8f8f2">$dir</span> <span style="color: #f92672">]]</span>
<span style="color: #f92672">}</span>


<span style="color: #75715e"># =================================================================</span>
<span style="color: #75715e"># end boilerplate</span>
<span style="color: #75715e"># =================================================================</span>

main
</pre></div>

  
</details>

Where you navigate to the case directory and run the following in order:

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">bash xml_config_helper.sh
bash case_build_helper.sh
./case.submit
</pre></div>


### Regridding output to a lat-lon grid:

Download the [following repository](https://github.com/mgduda/convert_mpas) and build the `convert_mpas` tool.

The tl;dr of how to use this tool is 

<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #66d9ef">${</span><span style="color: #f8f8f2">ABSOLUTE_PATH_TO_CONVERT_MPAS</span><span style="color: #66d9ef">}</span>/convert_mpas <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">GRID_DIR</span><span style="color: #66d9ef">}</span>/<span style="color: #66d9ef">${</span><span style="color: #f8f8f2">GRID_PREFIX</span><span style="color: #66d9ef">}</span>.init.nc <span style="color: #66d9ef">${</span><span style="color: #f8f8f2">ABSOLUTE_PATH_TO_NETCDF</span><span style="color: #66d9ef">}</span>/output_on_mpas_grid.nc
</pre></div>


The first file specifies all of the metric terms and topography that were used for your run. The second file is the output data.
After this command is finished it will have created a file called `latlon.nc` which you can view with your NetCDF
viewer of choice.

<span class="todo">If you run this command multiple times in the same directory, make sure to run `rm latlon.nc`
(or some similar command) in between. Even if the files have the same structure, calling the command again
will silently overwrite `latlon.nc` if it exists. If the variables or dimensions
of the file you're trying to regrid changes, it will do something very strange. I think it only regrids
the variables that exist in the existing `latlon.nc` file along the dimensions that exist.</span>