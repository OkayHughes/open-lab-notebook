---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: efficient IMEX
layout: layouts/post.njk
---

All we need to modify are the Jacobian terms for `$$\phi$$`. 
From the [IMEX preprint](https://arxiv.org/pdf/1906.07219.pdf)

`$$$ G_{m,j}(g_{m,j}^\phi) = g_{m,j} - E_{m,j}^\phi - g \Delta t \hat{A}_{j,j} E_m^w + (g \Delta t \hat{A}_{j,j})^2 (1-\mu_{m,j})$$$`

## top interface:

We define
`$$$
\begin{align*}
  a &= \frac{(\Delta t g(\phi_1))^2}{(1-\kappa)}\\
  b &= \frac{a}{\textrm{dp3d}_1}\\
  c_1 &= \frac{p_1}{\Delta \phi_1} \\
  J_{k-1, k} &= 2bc_1 \\
  J_{k, k} &= 1- 2bc_1 
\end{align*}
$$$`


## interior interfaces:

`$$$
\begin{align*}
  a &= \frac{(\Delta t g(\phi_k))^2}{(1-\kappa)}\\
  b &= 2\frac{a}{
  \left(\textrm{dp3d}_{k-1}+ \textrm{dp3d}_k\right)}\\
  c_k &= \frac{p_k}{\Delta \phi_k} \\
  J_{k+1, k} &= 2bc_{k-1} \\
  J_{k-1, k} &= 2bc_k \\
  J_{k, k} &= 1- bc_k - 
\end{align*}
$$$`


## bottom interface: