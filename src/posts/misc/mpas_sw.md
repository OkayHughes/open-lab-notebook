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

Try the command `make clean CORE=PREVIOUS_CORE_BUILD` if you have a previous build left on the filesystem

### Make shallow water core:

Try the command `make gfortran CORE=sw PRECISION=single`. Let's see what happens

Seems to need `make gfortran CORE=sw PRECISION=single USE_PIO2=true`.

This command seems to finish correctly. I'm going to search for either the Williamson or Galewsky shallow water test cases.

It appears that in the file `src/core_sw/mpas_sw_test_cases.F` there are several Williamson shallow water test cases.

### Trying to get `sw_test_case_2` working:
This is the "Global  steady state non-linear zonal geostrophic flow" test case.

First I'm going to see if I can find an example shallow water namelist on the mpas repository (I'm not hopeful.)

Turns out a good default namelist is found in `src/core_sw/default_inputs/namelist.sw` and `streams.sw`.




Let's try creating a case directory after the fashion of `core_atmosphere`:

The executable we need is `src/sw_model`.

The correct 
<details>
<summary>View create.sh </summary>
<p>
<pre>
<code>

</code>
</pre>
</p>
</details>
</details>


  




