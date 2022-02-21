---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Code outline
layout: layouts/post.njk
---

The locality of the `$$ H $$` matrix's components mean that the primary computational expense
is solving an extremely sparse matrix (each line of the system contains at most 4 non-zero entries on the LHS).

It is clear that formulation of the `$$ H $$` dynamic tangent matrix can be computed node-by-node in an embarassingly
parallel fashion. 

Presumably the main implementation of these libraries will use the parMETIS algorithm for graph partitioning
and Trilinos NOX for nonlinear solvers.

This is a good example of how to do this in an MPI compliant fashion:
  [source](https://github.com/trilinos/Trilinos/blob/master/packages/nox/examples/epetra/NOX_1DFEMNonlinear/FiniteElementProblem.C)

