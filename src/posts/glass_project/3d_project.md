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
* design for multiple GPUs (i.e. one MPI per GPU. This generalizes well to the cluster that I have)


## Construction and derivatives
Assume that `$$ \Omega = [-1, 1]^3$$`. Then `$$ ~_{lL}\mathbf{D}$$` is the derivative of 1D interpolant polynomials
on the GLL points. Then if we have a scalar quantity `$$u(x_1, x_2, x_3)$$` located at the GLL points `$$~_{l_1,l_2,l_3}\mathbf{U} $$` 
then `$$\partial_{x_i} u $$` is `$$~_{l_1l_2l_3}\mathbf{U}_{L=l_i}~_{lL}\mathbf{D}_{L}.  $$` This comes from the fact that 
`$$u(x_1, x_2, x_3) = \sum_{l_1,l_2,l_3=1}^{n_{GLL}} u_{l_1,l_2,l_3} p_{l_1}(\xi_{l_1})p_{l_2}(\xi_{l_2})p_{l_3}(\xi_{l_3}).$$`


Righthand side terms are computed within an element, then undergo DSS (direct stiffness summation) which involves intra-element communication. 
Since DSS is a jacobian-weighted average over all redundant points, and our Eulerian grid (which is a subset of Euclidean space) has
a Jacobian which is just the identity matrix, this means that our DSS procedure is just a sum which must take into account the number of redundant points.

Given that our viscosity has the form `$$\nu(T, S)$$` (in particular, it isn't flow dependent), we get some choice in
of prognostic equations. For the sake of education, I'm going to try to follow along with [this paper](https://drive.google.com/file/d/1hJajromVP15F-Ft_9g4fG_P6F2da2IP4/view?usp=sharing)

But I think I can basically just use the Navier Stokes equations as is. 


## Code:

Create abstract base class for an equation set 

