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

## Helmholtz

We start by implementing the helmholtz equation on a 2d domain
in order to learn how to express PDEs in the Firedrake methodology.

Let `$$\Omega$$` be the unit square and use `$$\Gamma$$` to denote the boundary.

The helmholtz equation with Neumann boundary conditions is
`$$$
\begin{align*}
 \nabla^2 u &= u - f \\
 \nabla u \cdot \mathbf{n} &= 0.
\end{align*}
$$$`

Let us use the galerkin formalism over a function space `$$V$$`.
Then let `$$v \in V$$` be a test function. 

We start by remembering how the variational problem is derived.
Start with `$$ \int_\Omega (u - \nabla \cdot( \nabla u))v \intd{\mathbf{x}} = \int_\Omega vf \intd{\mathbf{x}} $$`.
Integration by parts in cartesian coordinates gives
`$$$
\begin{align*}
  \int_\Omega (\nabla \cdot \nabla u) v \intd{\mathbf{x}} &= \int_\Omega \nabla v \cdot \nabla u - \nabla \cdot (v\nabla u) \intd{\mathbf{x}} \\
  &\stackrel{\textrm{div thm}}{=}\int_\Omega \nabla v \cdot \nabla u  \intd{\mathbf{x}} - \int_\Gamma v \nabla u \intd{\Gamma}
\end{align*}
$$$`
