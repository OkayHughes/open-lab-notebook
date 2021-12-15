---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Where to find files for modifying the shallow water core in the HOMME dynamical core.
  parent: E3SM
layout: layouts/post.njk
---


### Where to find the shallow water execution scripts
After following the installation structures given elsewhere, you can find the 
standard shallow water test cases in `${wdir}/tests/swtc{TEST_CASE_NUMBER}`.

The scripts within these directories called `swtc{TEST_CASE_NUMBER}-run.sh` 
will run shallow water test cases in using mpirun. These can be submitted
as batch scripts to `sbatch` defaultly, but honestly you don't even need to.
They run in around 60 seconds on the login nodes. 
The netcdf output appears in `movies`. Whee. 


### Where to modify initial conditions:
In order to modify the initial conditions, look in `${E3SM}/components/homme/src/sweqx/shallow_water_mod.F90`
and the subroutines named like `tc6_init_state`. 

