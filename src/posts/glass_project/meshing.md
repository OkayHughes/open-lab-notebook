---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Meshing
layout: layouts/post.njk
---

If hexahedral meshes could be used in our solver, the use of GLL basis elements would yield automatically mass-lumped finite element formulations
of our equations. While this is not strictly a requirement, I'm fairly sure it would improve parallel throughput if we go to GPU parallelism.
It significantly simplifies the sparsity structure of the global matrices and the assembly/stiffness summation procedure.

# Spatial twist continuum
A valid hexahedral mesh can be characterized using the
[Spatial Twist Continuum](https://www.sciencedirect.com/science/article/abs/pii/S0168874X97819567).
To each edge in the primal mesh, a dual 2-cell is associated. 