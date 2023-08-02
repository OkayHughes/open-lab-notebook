---
date: 2021-08-30
tags:
  - posts
  - finite volume
eleventyNavigation:
  parent: Transport Algorithms
  key: finite volume transport regular grid
layout: layouts/post.njk
---
We are solving the following equation
`$$$
\pder{}{t} \rho_i + \nabla \cdot (\rho_i\mathbf{F}) = 0
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

## horizontal differencing:
`$$C[\cdot]$$` is defined as follows:
`$$$
\begin{align*}
C[w] &= -\left[ \frac{H^x_{j+\frac{1}{2},k}(w) - H^x_{j-\frac{1}{2},k}(w)}{\Delta x} + \frac{H^y_{j,k+\frac{1}{2}}(w)-H^y_{j,k-\frac{1}{2}}(w)}{\Delta y} \right]
\end{align*}
$$$`


and we use the minmod limiter from the paper for simplicity, namely
`$`