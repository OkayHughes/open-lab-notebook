---
date: 2021-08-31
tags:
  - posts
  - directory
eleventyNavigation:
  key: clever steady state
layout: layouts/post.njk
---

We can formulate the equations of motion as
`$$$ \partial_t \mathbf{u} + \mathbf{F}(u) = \mathbf{f}(u) $$$`

We wish to find a steady state, namely `$$\partial_t u = 0$$`
which gives us the relation `$$ \mathbf{F}(u) - \mathbf{f}(u) = 0$$`

Let `$$ \mathbf{G}(u) = \mathbf{F}(u) - \mathbf{f}(u)$$`

Then we can root find using newton's method, namely 
`$$ \mathbf{u}_{n+1} = \mathbf{u}_n - J_\mathbf{G}(\mathbf{u})^{-1} \mathbf{G}(u) $$`

Here's the difficulty: how do we compute `$$J_{\mathbf{G}} $$`? 
The beauty of using a spectral method (c.f. the Guerra and Ullrich paper) is that
the method is global and this Jacobian is assumed to be dense. This induces a substantial
cost to increasing the order of your method; however, the computing derivatives with
respect to spectral coefficients is downright trivial. I much prefer the parallel scaling
of the spectral element dycore, however I'm unsure how computing such derivatives interacts
with the DSS (so-called direct stiffness summation)
step that's necessary to project solutions back into _continuous_ Galerkin space.
However, the HOMME codebase appears to have _fully implicit_ solver infrastructure,
which means that there may be a template for how to do this in a principled way.

Solving the linear equation is akin to any elliptic (I think) lumped FEM
method which means it would be sensible to do something like preconditioned GMRES.


## Using clues from HOMME:

In the file `${HOMME_ROOT}/share/prim_implicit_mod.F90`
we find a clue in the subroutine `residual`, which demonstrates
the infrastructure to solve 
`$$$ \mathbf{F}(\mathbf{u})  = \frac{(\mathbf{u}_{n+1} - \mathbf{u}_{n})}{\Delta t}  -  \textrm{DSS }\left[ \textrm{RHS}(\mathbf{u}_{n+1}) \right] $$$`

Under our assumptions we would revise this equation so `$$\mathbf{u}_{n+1} = \mathbf{u}_{n}$$`, i.e.

`$$$ \mathbf{F}(\mathbf{u})  -  \textrm{DSS }\left[ \textrm{RHS}(\mathbf{u}_{n+1}) \right] = 0$$$`

which seems like it may be a straightforward modification to make to the code?

I also note that in the C++ utilities, the Nox trilinos library is included, which 
is a general purpose nonlinear system solver that works with Kokkos.



