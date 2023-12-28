---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Working up to NS
layout: layouts/post.njk
---

## Current strategy (26-12-2023)
* Prototype stable numerical traditional FE method using firedrake
* Primary simulation interest is post-gather high-viscosity flow
where flow is essentially irrotational. We will deal with
domain overlap problems by remeshing. 
* This approach provides higher probability of experimentally determining a 
stable preconditioning method for dealing with complex constitutive equation
of glass at immobile/quasi-solid temperatures.
* The difficulty of the complex constitutive equation will probably have an approximate
splitting of the hard elliptical problem from the lagrangian velocity term.
The method pioneered in the work that started all this may be of use after all.

Currently I plan to use a Continuous Galerkin formulation for the full problem.
As the numerical difficulty of this problem results from the elliptic terms in the problem rather
than the hyperbolic ones (i.e. shocks will not predominate), 
I feel the additional complexity of DG methods aren't warranted.

# Working through Finite Elements and Fast Iterative Solvers
In order to build my understanding of where the difficulties arise
in solving the incompressible NS equations, I will be working through some of
(Finite Elements and Fast Iterative Solvers With Applications in Incompressible Fluid Dynamics)[https://academic.oup.com/book/27915].


## Poisson

The Poisson equation
`$$$
-\nabla^2 u = f
$$$`
is the prototypyical elliptic PDE. Typical (Robin) boundary
conditions can be expressed as
`$$$
 \alpha u + \beta \nabla u \cdot \mathbf{n} = g \textrm{ on } \partial \Omega.
$$$`
Robin boundary conditions encompass Dirichlet (`$$\beta = 0$$`) and 
Neumann (`$$\alpha = 0$$`) boundary conditions. 

In the Neumann case `$$ \nabla u \cdot \mathbf{n} = g$$`, the divergence theorem and 
the product rule for divergences gives us that
`$$$
  -\int_{\partial \Omega} \nabla u \cdot \mathbf{u} \intd{A} = - \int_\Omega \nabla \cdot \nabla u \intd{\mathbf{x}} = \int_\Omega f \intd{\mathbf{x}}
$$$`
but integrating the (strong version of) the Neumann boundary conditions, we find
`$$$
\int_{\partial \Omega} \nabla u \cdot \mathbf{n} \intd{A} = \intd_{\partial \Omega} g
$$$`
and we get a constraint that must be satisfied for the problem to be well-posed, namely
`$$$
   \int_{\partial \Omega} g + \int_\Omega f = 0
$$$`

Following the derivation we did in the other article here, under Neumann conditions we derive the weak form of the Poisson equation
`$$$
  \int_\Omega \nabla u \cdot \nabla v \intd{\mathbf{x}} = \int_\Omega vf + \int_{\partial \Omega} v (\nabla u \cdot \mathbf{n}) \intd{A} = \int_\Omega vf + \int_{\partial \Omega} vg \intd{A}.
$$$`
The quantities necessary to formulate the above weak problem naturally live in the space `$$\mathcal{H}^1(\Omega)$$`, which is the space of functions `$$u$$` which are weakly first differentiable .

A useful generic boundary problem that we will be implementing is
`$$$
-\nabla^2 u &= f \textrm{ on } \Omega \\
u = g_D \textrm{ on } \partial_D \Omega \\

$$$`