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
* The index for cubes will be `$$m$$`
* the index for cubical indices will be `$l_1,l_2,l_3$`
* The index for spectral coefficients will use variable `$$l$$`

## Design simplifications:
* 3D cubical domain.
* rigid among z and y boundaries, periodic among x boundary.
* `$$\nu = \nu(T, S) $$` with potentially wildly different stiffnesses depending on both tracer (glass color)
and temperature values.


## Construction and derivatives
Assume that `$$ \Omega = [-1, 1]^3$$`. Then `$$ ~_{lL}\mathbf{D}$$` is the derivative of 1D interpolant polynomials
on the GLL points. Then if we have a scalar quantity `$$u(x_1, x_2, x_3)$$` located at the GLL points `$$~_{l_1,l_2,l_3}\mathbf{U} $$` 
then `$$\partial_{x_i} u $$` is `$$~_{l_1l_2l_3}\mathbf{U}_{L=l_i}~_{lL}\mathbf{D}_{L}.  $$` This comes from the fact that 
`$$u(x_1, x_2, x_3) = \sum_{l_1,l_2,l_3=1}^{n_{GLL}} u_{l_1,l_2,l_3} p_{l_1}(\xi_{l_1})p_{l_2}(\xi_{l_2})p_{l_3}(\xi_{l_3}).$$`


