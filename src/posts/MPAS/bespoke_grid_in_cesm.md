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
to CIME.

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
  
```
module unload netcdf
module load intel/19.1.1  mpt/2.22
module load netcdf-mpi/4.7.4 pnetcdf/1.12.1 pio/2.5.2
```
</details>

and 
<details>
<summary><code>build.mpas.sh</code></summary>
  
```
make ifort CORE=init_atmosphere PRECISION=single USE_PIO2=true
make clean CORE=atmosphere
make ifort CORE=atmosphere PRECISION=single USE_PIO2=true  
```

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

**I make the assumption that you have generated the following files:**

* `${GRID_DIR}/${GRID_PREFIX}.grid.nc` contains a 2d representation of your MPAS grid connectivity.
* Several files `${GRID_DIR}/${GRID_PREFIX}.graph.info.part.${NPROC}` where `${NPROC}` includes
any number of MPI processes with which you want to run an MPAS model. It should probably be a multiple of the 
number of physical cores in a node within your cluster (or threads if your system has [HT](https://en.wikipedia.org/wiki/Hyper-threading, 
but I've had mixed success with this).
* `${GRID_DIR}/${GRID_PREFIX}.esmf.coupling.nc` which will be needed by the coupler within CAM.


## Step 1: Generating a 3D grid with metric terms

Follow one of the [MPAS tutorials](https://www2.mmm.ucar.edu/projects/mpas/tutorial/Boulder2019/index.html)
Use their tutorials to find an atmospheric configuration that matches the run you want to do (I'll explain what I mean in
a moment).

<span class="todo">Include a concrete example of what to do here</span>
Make sure to look in namelist files for referenced grid files and change them to 
your custom generated mesh files. I would recommended symlinking them to 
your case directory with 
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

<span class="todo">Todo: expand section about how to specify different vertical configurations.</span>



















