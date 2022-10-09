---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Mathematical quantities
layout: layouts/post.njk
---

## A brief note on indexing and notation
In order to keep track of tensors e.g. in point space and spectral space, I like to do the following:
* The index for tetrahedra will be `$$i$$`
* The index for vertex number will be `$$k$$` 
* The index for spectral coefficients will use variable `$$l$$`
* this allows us to write variables `$$_{IK}\mathbf{U}$$` and `$$_{IL}\mathbf{U}$$` which are two tensors containing, respectively, 
point evaluations of the quantity `$$U$$` on tetrahedron `$$i$$` and vertex `$$k = 0,1,2,3$$`, or basis function coefficients
to reconstruct `$$U$$` on tetrahedron `$$i$$` and basis function `$$l=0,1,2,3 $$`

## Design simplifications:
* 3D cubical domain.
* rigid among z and y boundaries, periodic among x boundary.
* `$$\nu = \nu(T, S) $$` with potentially wildly different stiffnesses depending on both tracer (glass color)
and temperature values.


## 