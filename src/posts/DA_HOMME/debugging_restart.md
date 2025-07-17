---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Explaining laplace_sphere_wk
layout: layouts/post.njk
---

## Basic principle:

Assume we're calculating the Laplacian on a domain without boundary (true on sphere, ish)

Recall A matrix `$$ A $$` can be characterized by its action on an orthonormal basis, e.g. `$$Ae_i = A_{:, i} $$`, `$$ e_i = (0, \ldots, \stackrel{i}{1}, ldots, 0) $$`,
and that `$$ e_j^\top A e_i = A_{j,i}$$` (i.e., we can extract the entries of a matrix by its action on "test vectors".

For this subroutine we recall that within an element, SE represents a scalar field as a sum `$$u = \sum_{i,j=1}^{\textrm{npts}} a_{i,j} \phi_j(x)\phi_i(y) $$`,
where `$$\phi_k(x)$$` is 1 at GLL point `$$k$$` and 0 at all other GLL points, and is a polynomial. _Spectral_ derivatives are calculated by differentiating the 
`$$\phi_k(x)$$` _analytically_ within the element, and then multiplying by a change of variables matrix (Dinv).

To calculate a weak derivative, you multiply your desired function `$$u$$` by a "test function" `$$v$$` which you know to be nicer.

Calculating the laplacian then looks like (assuming no boundary) 
`$$$
\begin{align*}
   \int (\nabla^2 u)v  \intd{A} &=\int (\nabla \cdot \nabla u) v \intd{A} \\
    &= \stackrel{\textrm{boundary term}}{0} - \int \nabla v \cdot \nabla{u} \intd{A}
\end{align*}
$$$`

The weak formulation allows you to formulate a laplacian for `$$u, v$$` that have only first derivatives. Without performing element assembly (direct stiffness summation),
`$$ \nabla u$$` calculated by `gradient_sphere` will not be continuous at boundaries, and so `$$ \nabla \cdot \nabla u$$` is not well defined.
This is why `divergence_sphere_wk` is called. 

The intermediate code comes in three sections.
The first conditional containing `grads(:,:,1) = grads(:,:,1)*mol_nu(:,:)` is for calculating molecular viscosity with a physically relevant nu.
The second conditional containing `if (hypervis_power/=0 ) then` is for when hyperviscosity coefficients are determined at each grid point.


The third conditional comes from an ad hoc redefinition of hyperviscosity that handles variable resolution. It is defined as
`$$
\tilde{\nabla}^2u = \nabla \cdot V \nabla u
$$`

There are several different methods for calculating `$$V$$` (none of which are physical, per se) but its purpose is to be able to input a constant value `nu_const` as, e.g., a namelist setting, and get reasonable hyperviscosity in a refined mesh.
 
 




