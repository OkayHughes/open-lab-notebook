---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Adding custom topography to CAM 
  parent: MPAS tutorials
layout: layouts/post.njk
---

## Introduction
A recent version of [the Community Atmosphere Model](https://github.com/ESCOMP/CAM/tree/cam_development)
added support for the Model for Prediction Across Scales (MPAS) atmospheric dynamical core.
MPAS is a dynamical core with support for a non-hydrostatic equation set built in. It is based on a C-grid discretization on
Spherical Centroidal Voronoi Tesselation (SCVT) horizontal mesh. As such 
it is designed to support variable resolution grids when it is run in its own codebase.
The CIME infrastructure that makes creating new cases and component sets 
necessarily limits the number of horizontal grid spacings that you can use.

This post is designed to show you how to add a new variable resolution MPAS grid
to CIME. <span class="todo">I have used this for aquaplanet runs, but I have not tried AMIP runs _yet_.</span>

In order to run this you will need access to a working standalone version of the MPAS-A model
available [here](https://github.com/MPAS-Dev/MPAS-Model).
I am working on a containerized version that is easy to run on a laptop [here](https://open-lab-notebook.glitch.me/posts/MPAS/singularity_mpas_def/)
which is currently a work in progress.

## Step -1: install MPAS

For the time being, I have [instructions](https://open-lab-notebook.glitch.me/posts/installing-mpas/) on how I installed MPAS on the [Great Lakes Cluster](https://arc.umich.edu/greatlakes/)
located at the University of Michigan.

If you have access to NCAR's Derecho, then your life is _much_ easier.

In order to compile MPAS on Derecho as of 2025-03-05, you can use the following scripts:

<details>
  <summary><code>setup.mpas.sh</code></summary>
  

<!-- HTML generated using hilite.me --><div style="background: #ffffff; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">module unload netcdf
module load ncarenv-basic/23.06  intel/2023.0.0  cray-mpich/8.1.25
module load parallel-netcdf/1.12.3 parallelio/2.5.10
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


## Step 0: Download a grid:
Download a grid from [here](https://mpas-dev.github.io/)

At this point I assume that you have a folder referred to by the variable `${GRID_DIR}`, and that
your grid has a unique prefix referred to in the variable `${GRID_PREFIX}`. This
prefix needs to uniquely identify your grid files so that they don't overlap with other MPAS files
in `${GRID_DIR}`.

In these instructions I will be using my particular use case as an example.
On Derecho, `GRID_DIR="${HOME}/grids/${GRID_PREFIX}/"` and `GRID_PREFIX="x4.92067"` where `x4` refers
to a 4x grid refinement in a band near the equator and the resulting grid has `92067` horizontal cells.
I'm going to call this grid `mpasa120-30` because on a full-radius grid it has a maximum grid spacing
of 120km and a minimum grid spacing of 30km.



**I make the assumption that you have generated the following files:**

* `${GRID_DIR}/${GRID_PREFIX}.grid.nc` contains a 2d representation of your MPAS grid connectivity.
* Several files `${GRID_DIR}/${GRID_PREFIX}.graph.info.part.${NPROC}` where `${NPROC}` includes
any number of MPI processes with which you want to run an MPAS model. It should probably be a multiple of the 
number of physical cores in a node within your cluster (or threads if your system has [HT](https://en.wikipedia.org/wiki/Hyper-threading), 
but I've had mixed success with this).



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
* Lines 2244-2275 are where metric terms are defined, but they use the `ah` and `zc` terms you modified earlier. You needn't modify any of this.

_Note: when you modify this code, you must rerun `make ifort CORE=init_atmosphere PRECISION=single`_. You can rename the resulting `init_atmosphere_model` that is generated in the `${MPAS_SRC_DIR}$` executable if you want to have multiple versions!


```
ln -s ${GRID_DIR}/${GRID_PREFIX}.grid.nc ${MPAS_CASE_DIR} 
ln -s ${GRID_DIR}/$GRID_PREFIX}.graph.info.part.${NPROC} ${MPAS_CASE_DIR}
```

Continue until you call `mpirun -n ${NPROC} ./init_atmosphere_model` which generates a NetCDF file 
that contains a dimension called `nVertLevels.` 
I'm going to assume that this file is moved to `${GRID_DIR}/${GRID_PREFIX}.init.nc`.

### Vital considerations:
As of 2025-03-06 the CAM MPAS implementation does not understand how to generate 3d metric terms for
MPAS. My understanding is that it knows how to correctly overwrite prognostic fields like edge wind flux
components.
As such, <span class="todo">_any topography that you intend to include in your CAM run must be in
  your `${GRID_DIR}/${GRID_PREFIX}.init.nc`_</span>

Similarly <span class="todo">_your vertical level number and location will be set by
creating this file. Ensure it matches the CAM vertical level configuration that you want to use._
</span>


If you are using a standard MPAS resolution that already has CIME defaults, then all you need to do to include the topography is to point the 
`ncdata` namelist parameter at your `${GRID_PREFIX}.init.nc`.

# Regridding output to a lat-lon grid:

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