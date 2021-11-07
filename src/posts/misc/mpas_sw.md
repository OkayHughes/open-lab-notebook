---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Building and running the MPAS shallow water core
layout: layouts/post.njk
---

## First steps:

Do the dependency process listed [here](https://open-lab-notebook.glitch.me/posts/installing-mpas)


## Shallow-water specific:

### Clean build system

Try the command `make clean CORE=${PREVIOUS_CORE_BUILD}` if you have a previous build left on the filesystem

### Make shallow water core:

Try the command `make gfortran CORE=sw PRECISION=single`. Let's see what happens

Seems to need `make gfortran CORE=sw PRECISION=single USE_PIO2=true`.

This command seems to finish correctly. I'm going to search for either the Williamson or Galewsky shallow water test cases.

It appears that in the file `src/core_sw/mpas_sw_test_cases.F` there are several Williamson shallow water test cases.

### Trying to get `sw_test_case_5` working:
This is the "Zonal flow over an idealized mountain" test case.

First I'm going to see if I can find an example shallow water namelist on the mpas repository (I'm not hopeful.)

Turns out a good default namelist is found in `src/core_sw/default_inputs/namelist.sw` and `streams.sw`.




Let's try creating a case directory after the fashion of `core_atmosphere`:

The executable we need is `src/sw_model`.

The correct file to get all of the dependencies set up (assuming you built with shared libraries) is
<details>
<summary>View setup.sh </summary>

```

module load gcc/8.2.0
export PATH=$scratch/dependencies/mpich/bin:$PATH
export MPICH_CC=gcc
export MPICH_FC=gfortran
export MPICH_F90=gfortran
export CC=mpicc
export FC=mpif90
export NETCDF=$scratch/dependencies/netcdf_c
export NETCDFF=$scratch/dependencies/netcdf_fortran
export PNETCDF=$scratch/dependencies/pnetcdf
export PIO=$scratch/dependencies/PIO
hdf5=$scratch/dependencies/hdf5
zlib=$scratch/dependencies/zlib
export MPAS_EXTERNAL_INCLUDES="-I$hdf5/include -I$zlib/include"
export MPAS_EXTERNAL_LIBS="-L${hdf5}/lib -L$zlib/lib -lhdf5_hl -lhdf5 -lz -ldl"
export LD_LIBRARY_PATH="$PNETCDF/lib:${NETCDF}/lib:${hdf5}/lib:${hdf5}/lib:${PIO}/lib:${NETCDFF}/lib:${LD_LIBRARY_PATH}"
export FFLAGS="-freal-4-real-8"

```

</details>

where you have to ensure that the shell variables point to the base directory of the 
corresponding dependency installs (i.e. it should have `bin`, `lib`, `include` subdirectories etc)



I created a case directory as follows:
```
mkdir ${MPAS_ROOT}/cases
mkdir ${MPAS_ROOT}/cases/shallow_water_test_case_5


ln -s ${MPAS_ROOT}/MPAS-skamaroc/sw_model ${MPAS_ROOT}/shallow_water/test_case_5/
# This copies the default namelists to our case version
cp ${MPAS_ROOT}/MPAS-skamaroc/src/core_sw/default_inputs/* ${MPAS_ROOT}/shallow_water/test_case_5/

```

where `MPAS_ROOT` is an absolute path to the directory. I have multiple source versions of MPAS in my `$MPAS_ROOT`
directory, hence why I've called one version `MPAS-skamaroc`. Yours is probably just called `MPAS` or something.

~~For cost's sake, I'll download the grid file from [here](http://www2.mmm.ucar.edu/projects/mpas/atmosphere_meshes/x1.2562.tar.gz)
with a nominal grid resolution of 480km.~~

~~From within your case directory, run~~
```
#wget http://www2.mmm.ucar.edu/projects/mpas/atmosphere_meshes/x1.2562.tar.gz
#tar -xf ./x1.2562.tar.gz

```

*NOTE: SEE BELOW, THESE GRID FILES ARE INCOMPATIBLE WITH THE SHALLOW WATER CORE AND MORE WORK IS NEEDED*. You can download a quickstart grid that
I generated [here](https://drive.google.com/file/d/1TEfbfk68jsO_NRYXNZZXbAr8qCBu9g7I/view?usp=sharing)

This gets you the mesh files.

In order to use my case management infrastructure, make sure that the `${mpas_output}` variable
points to a directory where you want to spit out mpas output files (which in general might be _very_ large).


I use a file called `CONFIG.sh` to configure my MPAS directory structure:



<details>
<summary>View CONFIG.sh </summary>

  
```
if [ -z ${mpas_output+x} ]
then
	echo "\$mpas_output is not set in the current environment"
	exit 1
fi

case_group="shallow_water"
casename="test_case_5"
# CHANGE THIS TO MATCH YOUR MPAS LOCATION
case_dir="${HOME}/MPAS/cases/${case_group}/${casename}"
out_dir="${mpas_output}/${case_group}/${casename}"
# MAKE SURE THIS AGREES WITH YOUR GRID FILES
grid_prefix="x1.2562"
log_dir="${case_dir}/logs"


# ==================================================
# Ensure configure variables are set correctly
# ==================================================

if [ -z ${case_dir+x} ] || [ -z ${out_dir+x} ] || [ -z ${casename+x} ] || [ -z ${grid_prefix+x} ] || [ -z ${log_dir+x} ]
then
	echo "CONFIG.sh is misconfigured, ensure it contains case_dir, out_dir, casename, grid_prefix, log_dir"
	exit 1
fi

if [ ! -d "${case_dir}" ]
then
	echo "Case directory ${case_dir} does not exist! "
	exit 1
fi

if [ ! -f "${case_dir}/${grid_prefix}.grid.nc" ] && [ ! -f "${out_dir}/${grid_prefix}.grid.nc" ]
then
	echo "File ${grid_prefix}.grid.nc should exist in either ${case_dir} or ${out_dir}"
	exit 1
fi

mkdir -p $out_dir 

mkdir -p $log_dir

```
  
</details>

where you need to make sure that `${case_dir}` actually points to your case directory.


Next, the slurm script I use to submit the job to the compute nodes in the cluster is given here:

<details>
<summary>View run.sh </summary>

```
  
#!/bin/bash

#SBATCH --job-name=sw_test_case_5

#SBATCH --mail-user=owhughes@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --time=12:00:00
#SBATCH --account=cjablono1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task 1
#SBATCH --nodes=1
#SBATCH --mem=1000m 

source ~/.MPAS/setup.bash

source CONFIG.sh


count=-1
if [ -f "${out_dir}/output.nc" ] 
then
	count=0
	while [ -f "${out_dir}/output.${count}.nc" ]
	do
		count=$((count+1))
	done
	echo "Moving ${out_dir}/output.nc to ${out_dir}/output.${count}.nc"
	mv ${out_dir}/output.nc ${out_dir}/output.${count}.nc
fi 

if [ -f "${out_dir}/diag.moist.nc" ]
then
	mv ${out_dir}/diag.moist.nc ${out_dir}/diag.moist.old.nc
fi

if [ ! -f "${case_dir}/${grid_prefix}.graph.info.part.${SLURM_NTASKS}" ] 
then
	echo "Missing ${grid_prefix}.graph.info.part.${SLURM_NTASKS} or a symlink to it"
	exit 1
fi

ln -sf "${case_dir}/${grid_prefix}.grid.nc" "${case_dir}/grid.nc"
ln -sf "${case_dir}/${grid_prefix}.graph.info.part.${SLURM_NTASKS}" "${case_dir}/graph.info.part.${SLURM_NTASKS}"

command="./sw_model"

current_dir=`pwd`
ls ${case_dir} | xargs -n1 -I {} ln -sf $case_dir/{} $out_dir/{}
cd $out_dir
mpiexec -bind-to=core -n ${SLURM_NTASKS} $command
find $out_dir -type l | xargs -n1 rm
cd $current_dir




run_log_dir=${log_dir}/run/$((count + 1))

mkdir -p ${run_log_dir}
if [ `ls $out_dir/log.* | wc -l` -gt 0 ]
then
	ls $out_dir/log.* | xargs -n1 -I {} mv {} ${run_log_dir}
fi
cp ${case_dir}/namelist.atmosphere ${run_log_dir}

```

</details>

Note that the file `setup.sh` should be sourced at the top of the run script, 
i.e., `source ${PATH_TO_SETUP}.sh` should come after the slurm directives a the top of the file.


## Running the model:


Make sure to configure `config_stop_time = "YEAR-MM-DD_HH:MM:SS"` in `namelist.sw`. 
I'm going to run for 5 days, or `config_stop_time = '0000-01-05_00:00:00'`.


## A problem

When I'm running the model I'm getting the following error:
```
CRITICAL ERROR: Dimension 'nTracers' required by field 'tracers' was neither read nor defined.
```

~~Which means that it's not generating an input file. I need to determine why that is.~~

~~The function `sw_core_init` in `core_sw/mpas_sw_core.F` probably has info.~~

~~Let's try to figure out where `sw_core_init` is called:~~

Ok so I've found the problem: in commit `55a0fc8ea754547434c847751d30a8bbf555572d` in the MPAS-tools
supplemental repository, the following problem is introduced:

>The periodic_hex mesh generator previously added fields to the grid.nc
file to serve as placeholders for ICs for the shallow-water model.
However, these fields are not part of the MPAS mesh specification, and
have been removed. Specifically, the following fields are deleted in
this commit:
*fEdge
*fVertex
*h_s
*u
*uBC
*v
*h
*vh
*circulation
*vorticity
*ke
*tracers
>Additionally, the dimensions nVertLevels and nTracers have also been
removed.

For more info see [this github issue](https://github.com/MPAS-Dev/MPAS-Tools/pull/241)

So this will take some cleverness:


## Building a modified MPAS-tools


<!--
Clone the repository []()

Run the following:
```

git checkout 50300ae871fb183421517b909fc4e6d1867f8829 -- mesh_tools/periodic_hex/module_write_netcdf.F
git checkout 50300ae871fb183421517b909fc4e6d1867f8829 -- mesh_tools/periodic_hex/periodic_grid.F
```


Make sure that you go into your netcdf dependencies and symlink all of the files in your netcdf_fortran `include, lib, bin` files
to your netcdf_c dependency `include, lib, bin` folders. 

Now run `make` in the directory `mesh_tools/periodic_hex/`

Note: running `./periodic_grid` will generate a mesh. The namelist options for this 
grid are given in `mesh_tools/periodic_hex/namelist.input`.

My example grid can be found at [this link](https://drive.google.com/file/d/1nvzUdMqfNWcUmBRP2m6QyBPTw4zyWVnd/view?usp=sharing)
-->

### Building the software:

Run:

```
git clone https://github.com/MPAS-Dev/MPAS-Tools.git.
cd MPAS-Tools/mesh_tools/points-mpas
```

Ensure that `${NETCDF}` points to a directory containing the `include, lib, bin` files for a static build of 
the netcdf-c and netcdf-c++ library. 

Install the netcdf-c++ library i.e. run ``` https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx-4.2.tar.gz ```
and use the `setup.sh` file from the netcdf-c setup. Symlink the contents of 
`$NETCDF_CPP_LOCATION/include` to `$NETCDF_C_LOCATION/include` and the same for the `lib` folder.


In the directory `MPAS-Tools/mesh_tools/points-mpas/` run `make`.



### Creating the input files to `PointsToMpas.x`
The main files you need to use to generate a grid are `SaveVertices`, `SaveTriangles` and `Params`. The `readme` for 
this code describes how it works. Change `Params` to use
lat-lon coordinates, e.g.


<details>
<summary>View Params </summary>
  
```
Is the input Cartesian or Latitude-Longitude (0 - Cartesian, 1 - Lat-lon)
1
Are the triangles base zero or base one? (0 - base 0, 1 - base 1)
1
What is the radius of the sphere these points are defined on?
1.0
How many vertical levels do you want in the output grid?
1
How many tracers do you want in the output grid?
1
What was the convergence criteria used to make this grid?
0.0
Should this grid be vordraw compatible?
0

```


</details>
The fact that the radius of the sphere is considered to be 1 is an MPAS default that exists in the prefab meshes that 
can be downloaded from MPAS' website.

You can use the following python script  to turn the files that you can download from [https://mpas-dev.github.io/] into `SaveVertices` and `SaveTriangles`
files. Start by doing something like

```
module load python3.8-anaconda;
yes | conda create --name mpas_gridding
conda activate mpas_gridding
yes | conda install netcdf4
yes | conda install xarray
```

Then you can use the following python script:

<details>
<summary>View mpas_to_text.py </summary>

```
import xarray as xr
import numpy as np

ds_disk = xr.open_dataset("x1.2562.grid.nc") #change this to the grid file downloaded from the MPAS website

edge_info = ds_disk["cellsOnEdge"].values
neighbors = {}
for edge_id in range(edge_info.shape[0]):
        edge = edge_info[edge_id]
        if edge[0] not in neighbors.keys():
                neighbors[edge[0]] = []
        if edge[1] not in neighbors.keys():
                 neighbors[edge[1]] = []
        neighbors[edge[0]].append(edge[1])
        neighbors[edge[1]].append(edge[0]) 

tris = set()
for cell in neighbors.keys():
        for neighbor in neighbors[cell]:
                for neighbor_2 in set(neighbors[cell]).intersection(set(neighbors[neighbor])):
                        tris.add(frozenset({cell, neighbor, neighbor_2}))


tris = np.array([list(x) for x in tris], dtype=np.int32)

lat_cell = ds_disk["latCell"].values
lon_cell = ds_disk["lonCell"].values
  
np.savetxt("SaveVertices", np.stack((lat_cell, lon_cell)).T, fmt="%.8f")
np.savetxt("SaveTriangles", tris, fmt="%d")
  
```

</details>

Once you have `SaveVertices` and `SaveTriangles` ,
copy them into the `MPAS-Tools/mesh_tools/points-mpas` directory (delete the file that's named something like `SaveDensity`). 
This generates a MPAS grid file called `grid.nc`
and a graph partitioning file called `graph.info`, see below for more on this.


### Grid decomposition

If you want to run MPAS in parallel (i.e. on 8 cores a 10 day shallow water run will take 11 seconds),
then you need to install Metis, which partitions MPAS grids for parallel computing, i.e. run

```
wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz

tar -xf metis-5.1.0.tar.gz
module load cmake/3.21.3
make
```

and follow the instructions. The result will be a file called `metis-5.1.0/build/Linux-x86_64/programs/gpmetis`,
and this can be invoked like 
```
${PATH_TO_METIS}/build/Linux-x86_64/programs/gpmetis ${PATH_TO_graph.info}/graph.info ${NPROCS}
```

which creates a `graph.info.part.${NPROCS}` file. Copy these into your MPAS directory. 
Make sure that your `grid.nc` file and your `graph.info.part.{}` have a prefix that agrees with `${grid_prefix}`
if you're using my `CONFIG.sh` script above. i.e. in this case I would rename `grid.nc` to `x1.2562.grid.nc` 
and `graph.info.part.8` to `x1.2562.graph.info.part.8`.



Once you do this you can run `sbatch run.sh` and a file will be generated in your `${MPAS_OUTPUT}/${case_name}`
directory called `output.nc`. Follow the instructions below to visualize this.


### Making `convert_mpas`

Make sure that you go into your netcdf dependencies and symlink all of the files in your netcdf_fortran `include, lib, bin` files
to your netcdf_c dependency `include, lib, bin` folders. 

Run 
```
git clone https://github.com/mgduda/convert_mpas.git
cd convert_mpas
source #${some setup.sh file that sets the necessary variables}
make
```

You can then run this like 
```
${PATH_TO_convert_mpas}/convert_mpas ${OPTIONAL_GRID_FILE} output.nc
```

In order to preserve features like topography, replace `${OPTIONAL_GRID_FILE}` with something like `x1.2562.grid.nc`.

This will create a netcdf file on a lat-lon grid which you can view by doing

```
module load ncview
ncview latlon.nc

```
  




