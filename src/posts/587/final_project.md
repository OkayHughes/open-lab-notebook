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
\begin{align*}
 T_{t_{i+1}, ijk} &= T_{t_{i}, ijk} + \Delta t \left( k\left(T_{ijk}\right)\left[\sum_{ijk} T_{ijk}(p_i''(x_i)p(y_j)p(z_k) + p_i(x_i)p_j''(y_j)p_k(z_k) + p_i(x_i)p_j(y_j)p_k''(z_k))\right] \right)\\
\end{align*}
$$$`
Working in implicit we get

`$$$
\begin{align*}
   0 &= (T_{t_{i+1}} - T_{t_{i}}) - \Delta t(k(T_{t_{i+1}}) \nabla^2 T_{t_{i+1}}) \\
   &= \left[(T_{t_{i+1}, ijk} - T_{t_{i}, ijk})\right] - \Delta t\left(k(T_{t_{i+1}, ijk}) \nabla^2 \sum_{ijk} T_{t_{i+1}, ijk} p_i(x)p_j(y)p_k(z) \right)\\
   &= \left[(T_{t_{i+1}, ijk} - T_{t_{i}, ijk})\right] - \Delta t\left(k(T_{t_{i+1}, ijk})  \left(\sum_{q} T_{t_{i+1}, qjk} p_q''(x_q) + T_{t_{i+1}, iqk}  p_q''(y_q) +  T_{t_{i+1}, ijq}  p_q''(z_q) \right)\right)
\end{align*}
$$$`

This is a system of algebraic equations 
`$$$
 G_{ijk}(T_{i'j'k'}) = 0
$$$`
and in order to solve this we must find 


