---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: eecs587
  key: final project 587
layout: layouts/post.njk
---


Suppose we have an advection equation
`$$\pder{T}{t} + \mathbf{v} \cdot \nabla T = 0$$`
which we're solving with `$$ u_d = \sum u_{dijk} p_i(x)p_j(y)p_k(z)$$` and
`$$ T = \sum T_{ijk} p_i(x)p_j(y)p_k(z) $$`

