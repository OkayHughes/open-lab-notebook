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


Suppose we have a diffusion equation
`$$\pder{T}{t} = k(T) \nabla^2 T$$`
which we're solving with MOL. We use spectral decomposition
`$$ T = \sum T_{ijk} p_i(x)p_j(y)p_k(z) $$`
Suppose we want to solve newton's method 
`$$ (T_{t_{i+1}} - T_{t_{i}}) - \Delta t(k(T) \nabla^2 T) = 0$$`
Let us work within a singular element. 
At a particular GLL node indexed by `$$ ijk $$`, if we 
were to use an explicit method then
`$$$
 T_{t_{i+1}}
$$$`


`$$$
\begin{align*}
   0 &= (T_{t_{i+1}} - T_{t_{i}}) - \Delta t(k(T) \nabla^2 T) \\
   &= \left[\sum_{ijk} (T_{t_{i+1}, ijk} - T_{t_{i}, ijk})p_i(x)p_\right] - \Delta t(k() \nabla^2 T) = 0
\end{align*}
$$$`


