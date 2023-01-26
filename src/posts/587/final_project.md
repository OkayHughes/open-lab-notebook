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
\mathbf{x} \mapsto \frac{\|\mathbf{x}\|_{2 + \frac{\|\mathbf{x}\|_\infty}{1 - \|\mathbf{x} \|_\infty}}}{\|\mathbf{x}\|_\infty} \mathbf{x}
\end{align*}
$$$`

Note: I think I've finally determined how to do covariant/contravariant vectors? Note that the euclidean structure into which our manifold is embedded gives us that for 
physical vectors `$$ \mathbf{u}, \mathbf{v} $$` then `$$\langle \mathbf{u}, \mathbf{v} \rangle =  \mathbf{u}_{p} \mathbf{v}^p.$$` Note that [this site](https://en.wikipedia.org/wiki/First_fundamental_form) 
gives that `$$\mathbf{g} = \mathbf{J}^\top \mathbf{J}.$$` This seems to indicate that covariant `$$ \mathbf{u}_\alpha = \mathbf{u}^\top (\mathbf{J}^{-1})^\top$$` and `$$ \mathbf{u}^\alpha =  \mathbf{J}^{-1}\mathbf{u}$$`
which gives
`$$$
\begin{align*}
\langle \mathbf{u}_\alpha, \mathbf{v}^\alpha \rangle &= \mathbf{u}^\top (\mathbf{J}^{-1})^\top \mathbf{g}  \mathbf{J}^{-1}\mathbf{v} \\
&= \mathbf{u}^\top (\mathbf{J}^{-1})^\top \mathbf{J}^\top \mathbf{J} \mathbf{J}^{-1}\mathbf{v} \\
&= \mathbf{u}^\top \mathbf{v} \\
\end{align*}
$$$`






## GMRES
We'll use the [wikipedia writeup](https://en.wikipedia.org/wiki/Generalized_minimal_residual_method) as a starting point, 
Suppose we have a system `$$ \tilde{\mathbf{A}}\mathbf{x} = \tilde{\mathbf{b}} $$` 
and in order to conform to the wikipidia conventions we use the modified equation `$$$ \left(\|\mathbf{b}\|^{-1}\tilde{\mathbf{A}}\right)\mathbf{x} = \|\mathbf{b}\|^{-1} \tilde{\mathbf{b}} \implies \mathbf{A} \mathbf{x}  = \mathbf{b} $$$`

We want to find a basis for the Krylov subspace
`$$$K_n = \textrm{span}\left(\mathbf{r}_0, \mathbf{A}\mathbf{r}_0, \mathbf{A}^2\mathbf{r}_0, \ldots, \mathbf{A}^{n-1}\mathbf{r}_0 \right) $$$`
where `$$\mathbf{r}_0 =  \mathbf{b}-\mathbf{A}\mathbf{x}_0.$$`

We use the convention that `$$ \mathbf{q}_0 = \|\mathbf{r}_0\|_2^{-1} \mathbf{r}_0 $$` to do the Arnoldi iteration. That is
* for `$$k=1,n-1$$`
* `$$\mathbf{q}_k = \mathbf{A} \mathbf{q}_{k-1} $$`
* for `$$j = 1,k-1$$`
  * `$$h_{j,k-1} = \langle \mathbf{q}_j, \mathbf{q}_k \rangle $$`
  * `$$ \mathbf{q}_k = \mathbf{q}_k - h_{j, k-1}\mathbf{q}_j $$`
* `$$ h_{k, k-1} = \|\mathbf{q}_k\| $$`
* `$$ \mathbf{q}_k = \frac{\mathbf{q}_k}{h_{k,k-1}} $$`


If we let `$$\mathbf{Q}_n$$` have as columns the `$$\mathbf{q}_n$$` computed above, 
the wikipedia page gives the form `$$\mathbf{A}\mathbf{Q}_n = \mathbf{Q}_{n+1} \mathbf{H}_n $$`
where the `$$ \mathbf{H}_{i,j} $$` coefficients are drawn from the
`$$ h_{j, k-1} $$` given above. This is a good checkpoint in the code to make sure I'm on the right track.

Let `$$\beta = \|\mathbf{r}_0\| $$`, then we need to find the vector  that minimizes `$$ \|\mathbf{b} - \mathbf{A} \mathbf{x}_n \| $$`
which can be found to be equivalent to minimizing  `$$ \|\mathbf{H}_n  \mathbf{y}_n - \beta \mathbf{e}_{1, n+1}\|$$`

# QR decomposition
We wish to find 
`$$$ \boldsymbol \Omega_n \tilde{\mathbf{H}}_n = \tilde{\mathbf{R}}_n $$$`
where `$$$\tilde{\mathbf{R}}_n = \begin {bmatrix} \mathbf{R}_n \\ 0 \end{bmatrix} $$$`
to account for the fact that `$$ \tilde{\mathbf{H}}_n$$` is an `$$(n+1)\times n$$` matrix.

In the subroutine where we update `$$\boldsymbol{\Omega}_n$$`, we are given `$$\boldsymbol{\Omega}_n$$`, `$$\tilde{\mathbf{H}}_{n} $$`, `$$\mathbf{h}_{n+1, n+2}$$` (which comes from the arnoldi iteration), `$$h_{n+2}.$$`
Define
`$$$\tilde{\mathbf{H}}_{n+1} = \begin{bmatrix} \tilde{\mathbf{H}}_n & \mathbf{h}_{n+1} \\ 0 & h_{n+1, n+2}\end{bmatrix} $$$`

Note that `$$$\begin{bmatrix}\boldsymbol{\Omega}_n & \boldsymbol{0} \\ \boldsymbol{0} & 1\end{bmatrix}\tilde{\mathbf{H}}_{n+1} = \begin{bmatrix} \mathbf{R}_n & \mathbf{r}_{n+1} \\ 0 & \rho \\ 0 & \sigma \end{bmatrix} $$$`
where `$$ \mathbf{r}_{n+1}$$`, `$$\rho$$` and `$$\sigma$$` can be computed by matrix-vector products, I think.

Assuming we have `$$c_n = \frac{\rho}{\sqrt{\rho^2 + \sigma^2}} $$` `$$s_n = \frac{\sigma}{\sqrt{\rho^2 + \sigma^2}} $$`.
define the Givens rotation `$$$ \mathbf{G}_n = \begin{bmatrix} \mathbf{I}_n & 0 & 0 \\ 0 & c_n & s_n \\ 0 & -s_n & c_n \end{bmatrix} $$$`
`$$$\boldsymbol{\Omega}_{n+1} = \mathbf{G}_n \begin{bmatrix}\boldsymbol{\Omega}_n & \boldsymbol{0} \\ \boldsymbol{0} & 1 \end{bmatrix}$$$`

and under this definition we find 
`$$$\boldsymbol{\Omega}_{n+1}\tilde{\mathbf{H}}_{n+1} = \begin{bmatrix} \mathbf{R}_n & \mathbf{r}_{n+1} \\ 0 & \sqrt{\rho^2 + \sigma^2} \\ 0 & 0 \end{bmatrix} $$$`
(this doesn't need to be computed, but can be verified as a check.)

Therefore writing 
`$$$ \beta \boldsymbol{\Omega}_n\mathbf{e}_1 = \begin{bmatrix} \mathbf{g}_n \\ \xi \end{bmatrix}  $$$`

then we find that `$$ \mathbf{R}_n \mathbf{y}_n =  \mathbf{g}_n$$`

Need: `$$\mathbf{Q}$$`, `$$\mathbf{H}$$`, `$$\boldsymbol{\Omega},$$` and `$$\mathbf{R}$$`

At a given step:
* Do arnoldi iteration to calculate `$$\mathbf{h}_{n+1}$$`, `$$h_{n+1,n+2}$$` and `$$\mathbf{q}_{n+1}.$$`
* Update `$$ \tilde{\mathbf{H}}$$` to form `$$\tilde{\mathbf{H}}_{n+1}$$`
* Update `$$ \mathbf{R}$$` to form `$$\mathbf{R}_{n+1}$$` via calculating `$$ \mathbf{r}_{n+1},$$` `$$\rho$$`, and `$$\sigma$$`.
* Calculate Givens rotation `$$\mathbf{G}_n$$` and use to compute `$$ \boldsymbol{\Omega}_{n+1}$$` (possibly can be done without storing `$$ \boldsymbol{\Omega}_n$$`).
* Use `$$\beta \boldsymbol{\Omega}_{n+1} e_1$$` to calculate `$$\mathbf{g}_n$$` and then compute `$$\mathbf{R}_{n+1}\mathbf{y}_{n+1} = \mathbf{g}_{n+1} $$`