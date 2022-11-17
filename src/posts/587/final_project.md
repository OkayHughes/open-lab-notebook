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
   &= \left[(T_{t_{i+1}, ijk} - T_{t_{i}, ijk})\right] - \Delta t\left(k(T_{t_{i+1}, ijk})  \left(\sum_{q} T_{t_{i+1}, qjk} p_q''(x_i) + T_{t_{i+1}, iqk}  p_q''(y_j) +  T_{t_{i+1}, ijq}  p_q''(z_k) \right)\right)
\end{align*}
$$$`

This is a system of algebraic equations 
`$$$
 G_{ijk}(T_{lmn}) = 0
$$$`
and in order to solve this we must find the matrix (after identifying `$$ ijk$$` and `$$lmn$$` with indices)
`$$\mathbf{G}$$` with
`$$$ 
\mathbf{G}_{ijk,lmn} = \partial_{T_{lmn}} G_{ijk}
$$$`
and for the above equations this gives
`$$$ 
\begin{align*}
  \mathbf{G}_{ijk,lmn} &= \partial_{T_{lmn}}\left[(T_{t_{i+1}, ijk} - T_{t_{i}, ijk})\right] - \Delta t\left(k(T_{t_{i+1}, ijk})  \left(\sum_{q} T_{t_{i+1}, qjk} p_q''(x_i) + T_{t_{i+1}, iqk}  p_q''(y_j) +  T_{t_{i+1}, ijq}  p_q''(z_k) \right)\right) \\
  &= \delta(ijk, lmn)  - \Delta t\bigg(\delta(ijk, lmn) k'(T_{t_{i+1}, ijk})  \left(\sum_{q} T_{t_{i+1}, qjk} p_q''(x_i) + T_{t_{i+1}, iqk}  p_q''(y_j) +  T_{t_{i+1}, ijq}  p_q''(z_k) \right)\\
  &+ k(T_{t_{i+1}, ijk}) \left(\delta(jk, mn)  p_l''(x_i) + \delta(ik, ln)  p_m''(y_j) + \delta(ij, lm) p_n''(z_k)  \right) \bigg)
\end{align*}$$$`
with `$$\delta(xyz, \alpha \beta \gamma)$$` is a kronecker delta operating on tuples `$$(x, y, z)$$` and `$$(\alpha, \beta, \gamma)$$`

## Let's do navier stokes:

`$$$
\begin{align*}
  \partial_t \mathbf{u} + \mathbf{u} \cdot \nabla \mathbf{u} - \nu(T) \nabla^2 \mathbf{u} &= -\frac{1}{\rho} \nabla p + \mathbf{g}\\
  \nabla \cdot \mathbf{u} &= 0\\
  \partial_t \rho + \mathbf{u} \cdot \nabla \rho &= 0 \\
  \partial_t T + \mathbf{u} \cdot \nabla T &= k \nabla^2 T
\end{align*}
$$$`

We use the split from the glass paper:
`$$$
\begin{align*}
0 &= \rho_{t+\Delta t} \left[ \hat{\mathbf{u}} - \mathbf{u}_{t}\right] + \Delta t \left( \rho_{t+\Delta t} (\hat{\mathbf{u}} \cdot \nabla \hat{\mathbf{u}}) + \nu (T_{t + \Delta t}) \nabla^2 \hat{\mathbf{u}} + \nabla p_{\textrm{guess}} - \mathbf{g} \right)\\
0 &= T_{t + \Delta t} - T_{t} + \Delta t \left( \hat{\mathbf{u}} \cdot \nabla T_{t + \Delta t} + \kappa \nabla^2 T_{t+\Delta t} \right)\\
0 &= \rho_{t+\Delta t} - \rho_{t} + \Delta t \left( \hat{\mathbf{u}} \cdot \nabla \rho_{t+\Delta t} \right)\\
p_{\textrm{guess}} &= p_{t} + \beta \Delta t \frac{1}{\rho_{t}} \nabla \cdot \hat{\mathbf{u}}
\end{align*}
$$$`
Repeat until converged.

`$$$
0 = \nabla \cdot \hat{\mathbf{u}} - \Delta t \nabla^2\left[ p_{t + \Delta t} - p_{\textrm{guess}} \right] + \tau \nabla^2 p_{t + \Delta t}
$$$`
Then a final non-divergent form
`$$$
0 = \rho_{t+\Delta t} \left[\mathbf{u}_{t+\Delta t} - \hat{\mathbf{u}} \right] + \Delta t\left(\rho_{t+\Delta t} (\mathbf{u}_{t+\Delta t} \cdot \nabla \mathbf{u}_{t+\Delta t}) + \nabla \left( p_{t+\Delta t} - p_{\textrm{guess}}) \right) \right)
$$$`

Note that `$$\tau \equiv \left(\frac{2\|\mathbf{u}\|}{h} + \frac{4\nu(T)}{h^2} \right)^{-1} $$`


## lagrangian SE decomposition
For a test of the curvilinear differential operators, we start with a position function `$$a(x)$$` which maps the unit cube `$$[-1, 1]^3 $$` to itself
with some sort of curvature. Let's try the function
`$$$ 
\begin{align*}
\mathbf{x} \mapsto \frac{\|\mathbf{x}\|_{f(r_{2k})}}{r_{2k}}\mathbf{x}\\
\end{align*}
$$$`
with `$$ k \gg 1 $$`,where we want `$$f(1) = 2k$$`, `$$f'(1) = 0$$`, `$$f(0) = 2,$$` `$$ f'(0) = 0.$$` Then we posit 
`$$ f(r) = ax^3 + bx^2 + cx + d,$$` and get
`$$$
\begin{align*}
  d&= 2\\
  c &= 0 \\
  3a + 2b &= 0\\
  a+b&=2(k-1)
\end{align*}
$$$`
and we solve to find `$$ b = 6(k-1)$$` and therefore `$$ a=-4(k-1)$$` so
`$$$
f(r) = -r(k-1)r^3 + 6(k-1)x^2 + 2 = 0
$$$`


