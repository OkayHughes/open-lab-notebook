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
\begin{align*}
-\nabla^2 u &= f \textrm{ on } \Omega \\
u &= g_D \textrm{ on } \partial \Omega_D \\
\nabla u \cdot \mathbf{n} &= g_N \textrm{ on } \partial \Omega_N \\
\partial \Omega &= \partial \Omega_D \sqcup \Omega_N
\end{align*}
$$$`

Note that solutions exist in the affine subspace of `$$\mathcal{H}^1$$` that is `$$\mathcal{H}^1_S = \{\mathcal{H}^1(\Omega) \mid u=g_d \textrm{ on } \partial \Omega_d \}$$` and test functions 
are in `$$\mathcal{H}^1_T = \{\mathcal{H}^1(\Omega) \mid u=0 \textrm{ on } \partial \Omega_d \}$$`. The test functions, while an affine subspace, are not a linear subspace.
So we get the following weak formulation
`$$$
  \int_\Omega \nabla u \cdot \nabla v \intd{\mathbf{x}} = \int_\Omega vf \intd{\mathbf{x}} + \int_{\partial \Omega_N} vg_N \intd{A} \textrm{ for all } v \in \mathcal{H}_T^1
$$$`
where we see that the restriction of `$$v$$` negates the contribution of the boundary integral on `$$\partial \Omega_D$$`.


## The (Bubnov-) Galerkin Method with boundary

Construct a good subspace `$$ \mathcal{S}_T \subset \mathcal{H}_T^1$$`, with basis functions `$$ \{\phi_i\}_{1 \leq i \leq n}$$`. Note that these basis functions satisfy the Dirichlet boundary condition.
Then choose additional basis functions `$$\{\phi_i\}_{n+1 \leq i \leq n+n_\partial} $$`
such that for some `$$u' \in \mathcal{S}_T$$` we can augment this function into`$$u' = u + \sum_{i=n+1}^{n+n_\partial} u_i \phi_i $$` to satisfy the Dirichlet boundary condition. 
My current understanding is that since the basis functions of `$$\mathcal{S}_T$$` are zero on the boundary, the appropriate choice of `$$n_\partial$$` will uniquely determine the
combination `$$ u_j $$`

