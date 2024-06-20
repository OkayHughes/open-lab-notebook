---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Differential geometry
  parent: math
layout: layouts/post.njk
---

We follow the hyperspeed introduction to differential geometry (not topology!) given in [this monograph](https://bookstore.ams.org/mmono-191)

Suppose we have a manifold `$$S$$` (without boundary), and let `$$\phi : S \to \mathbb{R}^n$$` be 
a coordinate chart `$$ \phi(p) = [\xi^1(p), \ldots, \xi^n(p)]$$`. 
If we have another suitably smooth coordinate chart `$$ \psi = [\rho^i]$$`,
we can define the coordinate transform `$$ \phi \circ \psi^{-1} : [\rho^i] \mapsto [\xi^i]$$`.
Use the usual tricks to define 

