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

This package plays very nicely with the `conda` environment manager for python. I cannot recommend enough 



Follow the installation instructions given at the top of spherical_grid.py
These routines assume that the radius of earth is a=6371 km but we needn't worry about this if we are using a reduced radius earth later. This only matters in that you will specify grid spacing in kilometers on a sphere of this radius, i.e. 30km~1 degree. 
The density function definition can be found in the function localrefVsLatLon inside jigsaw_util.py. My implementation of the above density function is given here.
My version of this code uses a radius that is reduced by a factor of two.
The command to invoke the grid generation is given on the second line in invoke.sh where the number after the -r flag specifies the radius on a sphere with radius 3185km. 
Invoking this command will create a folder called 120_30_grid which contains a file called 120_30_grid_mpas.nc which is the file which is the closest analogue of the mesh files provided on the MPAS website.
I copied this file to a new directory which I called 