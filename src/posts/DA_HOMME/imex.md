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



`$$$
\begin{align*}
  a &= \frac{(\Delta t g(\phi_1))^2}{(1-\kappa)}\\
  b &= \frac{a}{\textrm{dp3d}_{\textrm{int}, 1}}\\
  c_1 &= \frac{p_1}{\Delta \phi_1} \\
  J_L &= b_{k+1}c_k \\
  J_{U,k=1} &= 2b_kc_k \\
  J_{U,k=N} &= 0 \\
  J_{k, k} &= 1- 2bc_1 
\end{align*}
$$$`
