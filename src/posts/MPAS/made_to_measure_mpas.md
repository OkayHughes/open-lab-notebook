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


The function `localrevVsLatLon` inside of `jigsaw_util.py` defines the density function. In this project I 
care about creating a factor of 4 refinement of the grid in an axisymmetric band about the equator. 
If we define  the smallest grid spacing `$$r_0 =15\mathrm{km}, $$` the nominal width of the band of refinement `$$\varphi_0 = 7^\circ $$`
and the power which defines the sharpness of transition (larger power means sharper transition) to be `p = 4` then 
the density function which has units of kilometers is given by
`$$$ \textrm{dist}(\varphi) = r_0 \left(4 - 3 \left[ \frac{1}{\left(\frac{\varphi}{\varphi_0}\right)^p + 1} \right] \right) $$$`

My implementation of the above density function is given 

<details>
<summary>here:</summary>
  
```
def localrefVsLatLon(r, earth_radius=6371e3/2, p=False):
  """
  Create cell width array for this mesh on a locally refined latitude-longitude grid.
  Input
  ---------
  r : float
      minimun desired cell width resolution in km
  Returns
  -------
  cellWidth : ndarray
      m x n array of cell width in km
  lon : ndarray
      longitude in degrees (length n and between -180 and 180)
  lat : ndarray
      longitude in degrees (length m and between -90 and 90)
  """
  dlat = 0.125 #Make the lat-lon grid ~ 10x finer than resolution at equator, where 1deg ~ 100km
  dlon = dlat
  constantCellWidth = r  #in km

  nlat = int(180./dlat) + 1
  nlon = int(360./dlon) + 1

  lat = np.linspace(-90., 90., nlat)
  lon = np.linspace(-180., 180., nlon)

  lons, lats = np.meshgrid(lon, lat)

  if p:
      h = plt.contourf(lons, lats, dists)
      plt.axis('scaled')
      plt.colorbar()
      plt.show()

  #Parameters
  #------------------------------

  # Radius (in degrees) of high resolution area
  maxdist = 7
  #ratio of largest grid spacing to smallest grid spacing
  reduction_factor = 4.0
  # defines sharpness of transition. You can play with how this looks here:
  # https://www.desmos.com/calculator/xx4sypedm4
  power = 4



  # initialize with resolution = r (min resolution)
  factor = 1.0/(np.power(1/maxdist * lats, power) + 1)
  resolution = r * (reduction_factor - (reduction_factor-1) * factor)





  if p:
      h = plt.contourf(lons, lats, resolution, cmap="viridis", levels=100)
      plt.axis('scaled')
      plt.colorbar()
      plt.show()

  print(np.min(resolution), np.max(resolution))

  cellWidth = resolution #constantCellWidth * np.ones((lat.size, lon.size))

```
</details>

My version of this code uses a radius that is reduced by a factor of two.
The command to invoke the grid generation is given on the second line in invoke.sh where the number after the -r flag specifies the radius on a sphere with radius 3185km. 
Invoking this command will create a folder called 120_30_grid which contains a file called 120_30_grid_mpas.nc which is the file which is the closest analogue of the mesh files provided on the MPAS website.
I copied this file to a new directory which I called 