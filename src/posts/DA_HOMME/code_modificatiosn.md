---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Code modifications
layout: layouts/post.njk
---

# Finding and modifying the vertical integral
The idea is to do this by modifying the underlying subroutine. Hopefully one exists.
Geopotential used in NH model: called `phinh_i` (only at interfaces). 

In order to calculate a vertical integral, either `phinh_i` or `dp3d` must be referenced.

So: plan for tomorrow. 
0) Ensure deep atmosphere 2016 base state is available.  (Looks to be true!)
1) Modify EOS + elem ops following MT document
2) Identify as many vertical integrals as possible. Figure out how to change them.


# Assumptions
We assume that `$$\phi = g(r-R_0) $$` uses a constant `$$g$$` defined in the code by
`use physical_constants, only: g`. This means that computation of `dphinh_i` 
does not need to be changed.

# List of changes

## `dp3d`
We change the computation of `dp3d` according to `dp3d \equiv \hat{r}^2.`

In order to do this we first determine a way to calculate `$$r$$` on model 
interfaces as well as model levels.

Here is the first complication: midpoints are defined to be in the middle of the interval `$$s_{i,j-1}$$` and
`$$ s_{i, j}$$`. If `$$s$$` is not a height coordinate, then taking the average of `$$ \phi_{i, j-1} $$` and `$$\phi_{i, j} $$`
may not give the geometric midpoint of the interval. How, then, do we fix this?


