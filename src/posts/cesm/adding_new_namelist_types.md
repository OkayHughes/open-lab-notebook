---
date: 2021-09-01
tags:
  - posts
  - regridding
eleventyNavigation:
  key: Adding new namelist options
  parent: Community Earth System Model lifehacks
layout: layouts/post.njk
---

In this writeup I will add a namelist parameter to control the Brunt Vaisala frequency 
in the Jablonowski-Williamson 2006 dry baroclinic wave test case.

### definitions
I use `${SRCROOT}` to denote the root of your CAM source.

### how I figured out how to do this

In order to figure out how to set up this namelist parameter I first found one that 
should be available in the similar routines to the ones where I want to get this parameter. I used `analytic_ic_type`.

In order to figure out where this is used in the code run 
```
grep -r "analytic_ic_type" ${SRCROOT}
```

## Actually adding my own namelist

### step 1:
In the file `${SRCROOT}/bld/namelist_files/namelist_definition.xml`
add the following text 

<details>
<summary><code>namelist_definition.xml</code>  changes</summary>

```
<entry id="jw_06_BV_factor" type="real" category="dyn_test"
       group="analytic_ic_nl"
       valid_values="">
Factor by which to modify Brunt-Vaisala frequency in the moist baroclinic wave test case. Floating point.
May introduce static instability and rapid onset of turbuluence. Use with caution.
</entry>
```
  
</details>


the `id` field is what you will put e.g. in your `user_nl_cam` file e.g. `jw_06_BV_factor = 2.0`.
`type` is the Fortran type. Look around the `namelist_definition.xml` to find other `types`
and how to specify them.

_Important_: the `group` field will be used to get this parameter into Fortran. I think that the `category`
is used for generating documentation. It doesn't appear to be used in the code.

`valid values` is used primarily for `char` variables, but look elsewhere in the file for how to use it.

If you don't add a good description, I'm judging you.

### step 2:

In the file `${SRCROOT}/bld/namelist_files/namelist_defaults_cam.xml` add namelist defaults. 
I figured out how to do this by using `analytic_ic_type` as a reference in order to find the conditions under which
different defaults should be set.

I added the following defaults:

<details>
<summary>
  <code>namelist_defaults_cam.xml</code> changes  
</summary>
  
```
<jw_06_BV_factor > 1.0 </jw_06_BV_factor>
<jw_06_BV_factor phys="adiabatic"> 1.0 </jw_06_BV_factor>
<jw_06_BV_factor phys="kessler"> 1.0 </jw_06_BV_factor>
```
  
</details>

Chains of different CIME variables can be used e.g.
```
<jw_06_BV_factor phys="kessler" hgrid="C24"> 1.0 </jw_06_BV_factor>
```

### step 3:

This is going to vary based on which module you want to read your namelist variable from.
In order to figure out where this was done in my case I used grep to find a F90 file that contained 
`analytic_ic_nl.` In my case this is `${SRCROOT}/src/dynamics/tests/inic_analytic_utils.F90`. Where private 
module variables are declared, add e.g.

``` 
real                                         :: jw_06_BV_factor
```

There should be a line such 
as this where it actually reads in the variable:

```
namelist /analytic_ic_nl/ analytic_ic_type, jw_06_BV_factor
```

add your variable to this line, as I already did.

Next find the part of the file where the namelist is broadcast to all MPI ranks:

```
call mpi_bcast(jw_06_BV_factor, 1, mpi_real8, masterprocid, mpicom, ierr)
```

I followed the conventions of the `inic_analytic_utils` and created an getter function. At the top where
public interfaces are declared, add:

`public :: jw_06_brunt_vaisala ! accessor`

and add the definition of this function below the `contains` statement

```

real function jw_06_brunt_vaisala()
  jw_06_brunt_vaisala = jw_06_BV_factor
end function jw_06_brunt_vaisala

```


Another potential alternative to using a `private` variable with a getter function is using the 
`protected` keyword, in which subroutines within the module are allowed to modify this variable
but not modules that `use` the module in which it is defined.

Within the subroutine in which you call `mpi_bcast` before this is called, you can modify or validate the value
of your namelist variable. You can report issues using `write(iulog, *) msg` with `use cam_logfile, only: iulog` 
at the top of your module.


