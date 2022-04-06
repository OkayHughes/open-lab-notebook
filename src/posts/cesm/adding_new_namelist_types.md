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

In order to figure out where this is developed 