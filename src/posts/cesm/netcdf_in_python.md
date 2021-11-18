---
date: 2021-09-01
tags:
  - posts
  - cesm
eleventyNavigation:
  key: Getting started with NetCDF4 and Python.
  parent: Community Earth System Model lifehacks
layout: layouts/post.njk
---

This isn't authoritative and it probably won't be the best method for you, but
it's a good first step. I also don't know much about using python
on Windows outside of the WSL (Ubuntu but linux).


## Getting `miniconda`

Follow the instructions on [this site](https://docs.conda.io/en/latest/miniconda.html)
if you don't already have anaconda.

## The packages


### `NetCDF4`

Run `conda install -c anaconda netcdf4`. This is a low-level 
interface for reading `.nc` files efficiently. It's a pain to work with in most cases,
but you need to install this library so you can open Netcdf4 files (`scipy` only
can read netcdf3 and will throw weird errors).


### `xarray`

[Documentation](http://xarray.pydata.org/en/stable/getting-started-guide/quick-overview.html)
This is the nice interface that will allow you to manipulate data less painfully. It conforms
to the conventions of python libraries: `DataArrays` behave like numpy arrays with a few extra
moving parts, while `DataSet`s behave somewhat like Pandas dataframes. 
Run `conda install xarray`


### `Cartopy`

[Documentation](https://scitools.org.uk/cartopy/docs/latest/getting_started/index.html)
This is a plotting library that's really good
for geospatial data. It's sometimes a bit idiosyncratic but it's usually worth trying
if you want to make good global plots (it interfaces well with matplotlib).
Run `conda install cartopy`. 


## Optional:

### `wrf-python`

[Documentation](https://wrf-python.readthedocs.io/en/latest/installation.html)
This is from the Weather Research and Forecasting model and contains some useful interpolation
and geophysical routines. <span class="todo">Use with caution</span>, it uses variable conventions
that don't always agree with the models that generated the data you're working with.

Run `conda install -c conda-forge wrf-python`

### `pynio`

[Documentation](https://www.pyngl.ucar.edu/Nio.shtml)
This is a project that is slowly porting NCL's functionality to python, it's the one that Joe mentioned.
It might have what you're looking for, it might not. It's worth a look.
Run `conda install -cconda-forge pynio`




