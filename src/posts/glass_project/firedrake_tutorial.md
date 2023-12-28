---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Firedrake test
layout: layouts/post.njk
---


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
  &\stackrel{\textrm{div thm}}{=}\int_\Omega \nabla v \cdot \nabla u  \intd{\mathbf{x}} - \int_\Gamma v \nabla u \cdot \mathbf{n} \intd{\Gamma}
\end{align*}
$$$`
and so we get 
`$$$
\begin{align*}
  \int_\Omega \nabla u \cdot \nabla v + uv \intd{\mathbf{x}} &= \int_{\Omega} vf \intd{\mathrm{x}} + \int_\Gamma v \nabla u \cdot \mathbf{n} \intd{\Gamma} \\
  &= \int_{\Omega} vf \intd{\mathbf{x}} + 0.
\end{align*}
$$$`

we can use the method of constructed solutions and set the ansatz `$$ u= \cos(2\pi x) \cos(2 \pi y)$$` such that the boundary condition is
satisified and `$$f = (1.0 + 8.0\pi^2)\cos(2\pi x)\cos(2\pi y)$$`.


## Summary of how to use firedrake for linear variational problems
* Construct mesh
* Construct function space
* Get trial/test functions
* Construct governing equations
* Projection is done via the `interpolate` method on a `fd.Function` object.
* Pass to `fd.solve` which calls petsc

Note: `fd.dx` is a placeholder for integration over `$$\mathbb{R}^n$$`. 
For variational problems Neumann boundary conditions 
are incorporated into the variational formulation. Determining
the appropriate method of integrating over the boundary weakly must be determined.

## Code: 
```
import firedrake as fd
ne_x, ne_y = (10, 10)
mesh = fd.UnitSquareMesh(ne_x, ne_y)

cont_galerkin_deg = 1
cg_func_space = fd.FunctionSpace(mesh, "CG", cont_galerkin_deg)

trial_funcs = fd.TrialFunction(cg_func_space)
test_funcs = fd.TestFunction(cg_func_space) # there's jargon for when trial func space = test func space.
mesh_x, mesh_y = fd.SpatialCoordinate(mesh)
f = fd.Function(cg_func_space)
f.interpolate((1.0 + 8.0 * fd.pi**2) * fd.cos(mesh_x * fd.pi * 2) * fd.cos(mesh_y * fd.pi * 2))
a = (fd.inner(fd.grad(trial_funcs), fd.grad(test_funcs)) + fd.inner(trial_funcs,test_funcs)) * fd.dx
L = fd.inner(f, trial_funcs) * fd.dx

u = fd.Function(cg_func_space)

fd.solve(a==L, u, solver_parameters={'ksp_type': 'cg', 'pc_type': 'none'})

fd.File("/content/firedrake/helmholtz.pvd").write(u)

```

