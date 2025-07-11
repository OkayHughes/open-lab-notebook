---
date: 2021-08-30
tags:
  - posts
  - finite volume
eleventyNavigation:
  parent: Transport Algorithms
  key: finite volume transport on a regular grid
layout: layouts/post.njk
---
We are solving the following equation
`$$$
\pder{}{t} u + \nabla \cdot (u \mathbf{F}) = 0
$$$`
based on the Riemann-solver-free scheme for regular grids given [in this paper by Kurganov and Tadmor](https://www.sciencedirect.com/science/article/pii/S0021999100964593).

## Time stepping
We use the time stepping scheme given on p. 258 in the paper
`$$$
\begin{align*}
u^{(1)} &= u^{n} + \Delta t^{n} C[u^n] \\
u^{(l+1)} &= \eta_l u^{n} + (1-\eta_l)\left(u^{(l)}) + \Delta t^{n} C\left[u^{(l)}\right]\right),\quad l=1,\ldots, s-1\\
u^{n+1} &= u^{(s)}
\end{align*}
$$$`


## local propagation speeds

For a scalar equation, we define
`$$$
\begin{align*}
u^\pm_{j+\frac{1}{2}}(t) &= u_{j+ 1}(t) \mp \frac{\Delta x}{2}(u_x)_{j + \frac{1}{2} \pm \frac{1}{2}}(t), \\
u^\pm_{j-\frac{1}{2}}(t) &= u_{j- 1}(t) \stackrel{?}{\pm} \frac{\Delta x}{2}(u_x)_{j - \frac{1}{2} \pm \frac{1}{2}}(t)
\end{align*}
$$$`
so we can define
`$$$
a_{j\pm\frac{1}{2}}(t) = \max_{u \in [u^-_{j\pm \frac{1}{2}}, u^+_{j\pm\frac{1}{2}}]} |f'(u)|
$$$`
but since we are using a flux which is linear in `$$u,$$` this value is constant and so this reduces to `$$a_{j+\frac{1}{2}} = |F(t, x)|$$`

## horizontal differencing:
`$$C[\cdot]$$` is defined as follows:
`$$$
\begin{align*}
C[w] &= -\left[ \frac{H^x_{j+\frac{1}{2},k}(w) - H^x_{j-\frac{1}{2},k}(w)}{\Delta x} + \frac{H^y_{j,k+\frac{1}{2}}(w)-H^y_{j,k-\frac{1}{2}}(w)}{\Delta y} \right]
\end{align*}
$$$`


and we use the minmod limiter from the paper for simplicity, namely
`$$$
\begin{align*}
  (u_x)_{j,k}^n &= \textrm{minmod }\left(\theta \frac{u_{j,k}^n - u_{j-1,k}^n}{\Delta x}, \frac{u_{j+1,k}^n - u_{j-1,k}^n}{2\Delta x}, \theta \frac{u_{j+1,k}^n - u_{j,k}^n}{\Delta x}\right), \qquad 1\leq \theta \leq 2\\
  (u_y)_{j,k}^n &= \textrm{minmod }\left(\theta \frac{u_{j,k}^n - u_{j,k-1}^n}{\Delta y}, \frac{u_{j,k+1}^n - u_{j,k-1}^n}{2\Delta y}, \theta \frac{u_{j,k+1}^n - u_{j,k}^n}{\Delta y}\right), \qquad 1\leq \theta \leq 2\\
  \textrm{minmod}[a, b] &= \frac{1}{2}[\textrm{sgn}(a) + \textrm{sgn}(b)] \cdot \min(|a|,|b|)
\end{align*}
$$$`

and we finish by defining
`$$$
\begin{align*}
  H^x_{j\pm\frac{1}{2},k}(t) &= \frac{f(u^+_{j\pm\frac{1}{2},k}(t)) + f(u^-_{j\pm\frac{1}{2},k}(t))}{2} - \frac{a^x_{j\pm \frac{1}{2},k}(t)}{2}\left[u^+_{j\pm \frac{1}{2},k}(t) - u^-_{j\pm \frac{1}{2},k}(t) \right]\\
  H^y_{j,k\pm\frac{1}{2}}(t) &= \frac{g(u^+_{j,k\pm\frac{1}{2}}(t)) + g(u^-_{j,k\pm\frac{1}{2}}(t))}{2} - \frac{a^y_{j,k\pm\frac{1}{2}}(t)}{2}\left[u^+_{j,k\pm\frac{1}{2}}(t) - u^-_{j,k\pm\frac{1}{2}}(t) \right]
\end{align*}
$$$`

Note that evaluation of `$$f,g$$` occur only at `$$j \pm \frac{1}{2}, k\pm \frac{1}{2} $$` points, respectively. This indicates that we are implicitly working on an arakawa C grid. 
Since we are assuming that the domain is `$$\mathbb{T}^2$$`, this means that we can assume that `$$f_{-\frac{1}{2},k} = f_{n+\frac{1}{2},k}$$` and likewise `$$f_{j, -\frac{1}{2}} = f_{j, n+\frac{1}{2}}$$`.
This, therefore, resolves any ambiguity surrounding the flux used to compute `$$ a_{j\pm\frac{1}{2}}(t) = \max_{u \in [u^-_{j\pm \frac{1}{2}}, u^+_{j\pm\frac{1}{2}}]} |f'(u)| $$`


We find that the construction of the numerical fluxes gives
`$$$
\begin{align*}
  \frac{1}{2}\left[f(u_r  + u_l) - |f|(u_r-u_l) \right] &= \frac{1}{2}\left[(f-|f|) u_r  + (f+|f|) u_l  \right]
\end{align*}
$$$`
which is implicit upwind biasing. 

Note: do not accidentally solve the equation
`$$$ 
\pder{\rho}{t} + \nabla \cdot (\rho^2 \mathbf{u}) = 0
$$$`