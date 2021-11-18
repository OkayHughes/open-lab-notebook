---
date: 2021-09-01
tags:
  - posts
  - cesm
eleventyNavigation:
  key: Getting started with NetCDF4 and Python.
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
interface for reading `.nc` files efficiently. It's a pain to work with in most cases.


### `xarray`

Run ``
This is the nice interface that will allow you to manipulate data less painfully.


