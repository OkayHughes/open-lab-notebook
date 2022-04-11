---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Creating a Made to Measure MPAS grid.
  parent: MPAS tutorials
layout: layouts/post.njk
---

## How to create a variable resolution MPAS grid for the MPAS-A model.

<span class="todo"> Add introduction here</span>

I'm doing this work on NCAR's cheyenne so I defaultly have access to the Netcdf cinematic universe without much setup.

## Step 0: get code

I based my code on the wonderful repository that Pedro Peixoto has put online, which can be found [here](https://github.com/pedrospeixoto/MPAS-PXT).
However, I have uploaded my modified version of the code [here](https://github.com/OkayHughes/MPAS_grid_gen)


## Step 1 installation:

This package plays very nicely with the `conda` environment manager for python. I cannot recommend enough following
an install process based on this toolkit. A minimal `conda` install can be done by running one of the scripts
found [here](https://docs.conda.io/en/latest/miniconda.html) (it doesn't even need `root` permissions!!).

Once you have your shell configured to run `conda`, you can follow these instructions:
asdfasdf
<details>
  <summary><code>create_env.run_once.sh</code></summary>
  
```
conda create --name mpas_grid_gen python=3.8 
# I typically specify a python version which differs
# from the system version so that e.g. python and python3 both
# point to the conda version of python.
conda activate mpas_grid_gen
conda install --file dev-spec.txt
conda install mpas_tools
```
  
</details>


Actually running the code must be done after running `conda activate mpas_grid_gen`.


<span class="todo">Warning: the original code from Peixoto specifies grid spacings in km on a sphere
of radius `$$a=6371\mathrm{km} $$` but my code uses a reduced radius sphere with `$$a=3185\mathrm{km} $$`</span>
These routines assume that the radius of earth is a=6371 km but we needn't worry about this if we are using a reduced radius earth later. This only matters in that you will specify grid spacing in kilometers on a sphere of this radius, i.e. 30km~1 degree. 
The density function definition can be found in the function localrefVsLatLon inside jigsaw_util.py. My implementation of the above density function is given here.
My version of this code uses a radius that is reduced by a factor of two.
The command to invoke the grid generation is given on the second line in invoke.sh where the number after the -r flag specifies the radius on a sphere with radius 3185km. 
Invoking this command will create a folder called 120_30_grid which contains a file called 120_30_grid_mpas.nc which is the file which is the closest analogue of the mesh files provided on the MPAS website.
I copied this file to a new directory which I called 