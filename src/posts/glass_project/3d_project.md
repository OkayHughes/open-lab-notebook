---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: 3d eulerian
layout: layouts/post.njk
---

## A brief note on indexing and notation
In order to keep track of tensors e.g. in point space and spectral space, I like to do the following:
* The index for cubes will be `$$i$$`
* The index for dimension `$$k$$` 
* The index for spectral coefficients will use variable `$$l$$`
* this allows us to write variables `$$_{IK}\mathbf{U}$$` and `$$_{IL}\mathbf{U}$$` which are two tensors containing, respectively, 
point evaluations of the quantity `$$U$$` on tetrahedron `$$i$$` and vertex `$$k = 0,1,2,3$$`, or basis function coefficients
to reconstruct `$$U$$` on tetrahedron `$$i$$` and basis function `$$l=0,1,2,3 $$`

## Design simplifications:
* 3D cubical domain.
* rigid among z and y boundaries, periodic among x boundary.
* `$$\nu = \nu(T, S) $$` with potentially wildly different stiffnesses depending on both tracer (glass color)
and temperature values.


## Construction and derivatives
Assume that `$$ \Omega = [-1, 1]^3$$`. Then `$$ ~_{lL}\mathbf{D}$$` is the derivative of 1D interpolant polynomials
on the GLL points. Then if we have a scalar quantity located at the GLL points `$$~_{l_1l_2l_3} $$`