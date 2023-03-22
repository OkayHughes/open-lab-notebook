---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Installing NCL on greatlakes (03/22/2023)
  parent: NCL Script Documentation
layout: layouts/post.njk
---

# Installing via Conda

## 1. Install conda:

* Follow [this link](https://docs.conda.io/en/latest/miniconda.html) and download the Linux 64-bit (that is, x86_64) installer script. 
* Run `bash ${FILE_NAME}` substituting the name of the downloaded script (it begins with `Miniconda` if you want to use tab completion).
* Follow the prompts. Ensure that the conda root is located on a partition that can hold several gigabytes of data. That is,
if you use the default directory `${HOME}/miniconda3/`, then installed software counts against your `home` allocation on Greatlakes.
For me this has only been an issue if I'm installing Cuda versions.

## Create a conda environment and install ncl

* Create a conda environment using the command `conda create --name ${NCL_ENV_NAME} -c conda-forge ncl` (or whatever you want your environment to be named-if you forget,
you can run `conda info --env` to find all the conda environments on your system). *This only needs to be run once.*
* Run `conda activate ${NCL_ENV_NAME}`. *After installation, this must be run any time you want to access the* `ncl` *command*.

And you're done!


## Installing from source:
On a non-x86_64 machine, binaries may not be available from conda







