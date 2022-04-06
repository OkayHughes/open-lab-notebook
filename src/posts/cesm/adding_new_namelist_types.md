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

### Actually adding my own namelist

In the file `${SRCROOT}/bld/namelist_files/namelist_definition.xml`
add the following text 

<details>
<summary>namelist_definition.xml  changes</summary>

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

`valid values` is used primarily for `char` variables 