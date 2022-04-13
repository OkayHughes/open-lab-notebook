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

In these instructions I will be using my particular use case as an example.
On Cheyenne, `GRID_DIR="${HOME}/grids/${GRID_PREFIX}/"` and `GRID_PREFIX="x4.92067"` where `x4` refers
to a 4x grid refinement in a band near the equator and the resulting grid has `92067` horizontal cells.
I'm going to call this grid `mpasa120-30` because on a full-radius grid it has a maximum grid spacing
of 120km and a minimum grid spacing of 30km.



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





## Modifying CIME!


### Modifications to `${CAM_ROOT}/bld/namelist_files/namelist_defaults_cam.xml`


#### analytic initialization grid files
In this file there are lines reading something like 
```
<ncdata hgrid="mpasa120" nlev="32" analytic_ic="1" phys="cam_dev" >atm/cam/inic/mpas/mpasa120_L32_topo_coords_c201022.nc</ncdata>
```

Here `mpasa120` refers to an approximately `$$1^\circ $$` grid with a nominal grid spacing of 120km. 
These files are used in the case that you are starting from analytic initial conditions, such as 
the [UMJS Moist Baroclinic Wave](https://www.cesm.ucar.edu/models/simpler-models-indev/fkessler/index.html)
which can be used to spin up aquaplanets. The purpose of these files is
to provide vertical levels and associated metric terms for such a run. 

I make use of the file that I generated using the standalone version of MPAS, and make the following definition

```
<ncdata hgrid="mpasa120-30" nlev="32" analytic_ic="1" >/glade/u/home/owhughes/grids/x4.92067/x4.92067.init.nc</ncdata>
```

#### problem: `bnd_topo` grid file
The definition 
```
 <bnd_topo hgrid="mpasa120" >atm/cam/topo/mpas/mpas_120_nc3000_Co060_Fi001_MulG_PF_Nsw042_c200921.nc</bnd_topo>
```
sets the location of a topography file. <span class="todo"> I don't know how to generate
this file yet.</span> 


#### `drydep_srf_file`

The definition
```
<drydep_srf_file hgrid="mpasa120">atm/cam/chem/trop_mam/atmsrf_mpasa120_c090720.nc</drydep_srf_file>
```
defines land use fields that are required when doing an aquaplanet run for some reason.

For the sake of my current runs I create a dummy file which has the correct dimensions but all
fields are identically 0. Assuming that you have access to the `xarray` and `numpy` python packages (
e.g. by installing [miniconda](https://docs.conda.io/en/latest/miniconda.html) and running `conda install xarray`)
then you can use the following python script:

<details>
  <summary><code>create_srf.py</code></summary>
  
```
import xarray as xr
import numpy as np

ncol = 92067 # modify this to match your grid!
nclass = 11
nmonth = 12
fraction_landuse = np.zeros((nclass, ncol))
soilw = np.zeros((nmonth,ncol))
ds = xr.Dataset(
    {
       "fraction_landuse": (["class", "ncol"], fraction_landuse),
        "soilw": (["month", "ncol"], soilw),
    }
 )


ds.to_netcdf(path="atmsrf_mpasa120-30.nc")

```
  
</details>


I then add the following definition to the xml file:

```
<drydep_srf_file hgrid="mpasa120-30">/glade/u/home/owhughes/grids/x4.92067/atmsrf_mpasa120-30.nc</drydep_srf_file>
```

#### Default timestep and diffusion:

You will find a line similar to 
```
<mpas_dt hgrid="mpasa120"     >  900.0D0 </mpas_dt>
```

This sets the dynamics timestep for the MPAS dynamical core. <span class="todo">
You will need to set `ATM_NCPL` using `./xmlchange` so that the total physics timestep
(i.e. `86400/ATM_NCPL`) is an integer multiple of `mpas_dt`. Otherwise CAM will throw a
runtime error right at the beginning of the run.</span>

This time step is chosen to obey numerical stability conditions (namely the [CFL](https://en.wikipedia.org/wiki/Courant%E2%80%93Friedrichs%E2%80%93Lewy_condition) condition).
For practical purposes, `900.0` seconds is sufficient for a `$$1^\circ $$` grid. When you halve the 
horizontal grid spacing, you must also halve the time step. Accordingly, for a grid with
minimum grid spacing `$$\frac{1}{4}^\circ $$`,
a timestep of 200 seconds is sufficient. I thus add the line

```
<mpas_dt hgrid="mpasa120-30"     >  200.0D0 </mpas_dt>
```

MPAS's default diffusion scheme requires only one parameter 
which is set via a line like 
```
<mpas_len_disp hgrid="mpasa120">120000.0D0</mpas_len_disp>
```

This value is set to the minimum grid spacing in meters, and thus we add

```
<mpas_len_disp hgrid="mpasa120-30">30000.0D0</mpas_len_disp>
```

#### Block decomposition files:

You will find a line similar to
```
<mpas_block_decomp_file_prefix hgrid="mpasa120">atm/cam/inic/mpas/mpasa120.graph.info.part.</mpas_block_decomp_file_prefix>
```

Here we leverage the processor decompositions we created when we generated our grid (mind you,
if you want to change the number of processors you're using for your run, you must ensure that
you have a suitable file in your `${GRID_DIR}` directory.) I thus add the line:

```
<mpas_block_decomp_file_prefix hgrid="mpasa120-30">glade/u/home/owhughes/grids/x4.92067/x4.92067.graph.info.part.</mpas_block_decomp_file_prefix>
```



### Modifications to `${CAM_ROOT}/cime/config/cesm/config_grids.xml`
Note we have changed xml files
#### Defining a grid alias

In this file you will find a snippet of text similar to
```
    <model_grid alias="mpasa120_mpasa120" not_compset="_POP">
      <grid name="atm">mpasa120</grid>
      <grid name="lnd">mpasa120</grid>
      <grid name="ocnice">mpasa120</grid>
      <mask>gx1v7</mask>
    </model_grid>
```

This defines the grids on which different components are defined. So far I have only
run aquaplanet simulations which are fairly robust to grid changes. The following definitions
work for running aquaplanet configurations but may break if you try to run AMIP.
<span class="todo">Test whether this is true lol.</span>
I add the following lines for my custom grid:

```
    <model_grid alias="mpasa120-30_mpasa120-30" not_compset="_POP">
      <grid name="atm">mpasa120-30</grid>
      <grid name="lnd">mpasa120-30</grid>
      <grid name="ocnice">mpasa120-30</grid>
      <mask>gx1v7</mask>
    </model_grid>
```

This will allow us to do something like the following when we're creating a new case:
```
${SRC_DIR}/cime/scripts/create_newcase --compset "${COMPSET}" --res "mpasa120-30_mpasa120-30" --case ${CASE_DIR}/${CASE_NAME} --run-unsupported --project ${PROJECT} --pecount ${NPROCS}

```
which uses the alias we set in the xml snippet above.

#### Creating a grid specification
We find a snippet of text like
```
    <domain name="mpasa120">
      <nx>40962</nx> <ny>1</ny>
      <mesh driver="nuopc">$DIN_LOC_ROOT/share/meshes/mpasa120z32_ESMFmesh_cdf5_c20210120.nc</mesh>
      <desc>MPAS-A 120-km quasi-uniform mesh:</desc>
    </domain>
```
The `mesh` specification is what will force us to use the `${GRID_PREFIX}.esmf.coupling.nc` that we 
created above. Because MPAS is an unstructured grid, the only dimension you 
need to specify is the `nx` tag, which contains the number of columns. In my case I add
the following text:
```
    <domain name="mpasa120-30">
      <nx>92067</nx> <ny>1</ny>
      <mesh driver="nuopc">/glade/u/home/owhughes/grids/x4.92067/x4.92067.esmf.coupling.nc</mesh>
      <desc>MPAS-A 120km-30km variable resolution grid:</desc>
    </domain>
```





