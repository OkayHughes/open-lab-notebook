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
