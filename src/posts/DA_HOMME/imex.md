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

which gets translated into (dicarding any terms that disappear under differentiation),

`$$$ C_1 - \sum(\delta \phi) - C_2 - C_3  - (g\Delta t A_{j,j})^2\mu_{m,j} $$$`.
The tricky thing is that we are calculating this quantity at model interfaces, which means
and so we find
`$$$
\begin{align*}
  \mu_k &= \frac{p_{k+1} - p_k}{\frac{1}{2}(\textrm{dp3d}_{k+1} + \textrm{dp3d}_k)}\\
  &= (\textrm{dp3d}_i)^{-1} \left[\frac{}{} \right]
\end{align*}
$$$`

`$$$
\begin{align*}
  a &= \frac{(\Delta t g(\phi_1))^2}{(1-\kappa)}\\
  b &= \frac{a}{\textrm{dp3d}_{\textrm{int}, 1}}\\
  c_1 &= \frac{p_1}{\Delta \phi_1} \\
  J_L &= b_{k+1}c_k \\
  J_{U,k=1} &= 2b_kc_k \\
  J_{U,k\neq 1} &= b_k c_k \\
  J_{D, k=1} &= 1- J_{U, 1} \\
  J_{D, k \neq 1} &= 1-J_{L,k-1} - J_{U, k}
\end{align*}
$$$`

where we can expand
`$$$
\begin{align*}
  b_m c_n &= \frac{(\Delta t g(\phi_m))^2}{(1-\kappa) \cdot \textrm{dp3d}_{\textrm{int}, m}} \cdot \frac{p_n}{\Delta \phi_n}\\
  &= \frac{(\Delta t g(\phi_m))^2}{(1-\kappa) \cdot \textrm{dp3d}_{\textrm{int}, m}} \cdot \frac{p_n}{\Delta \phi_n}\\
\end{align*}
$$$`


The trick comes from differentiating `$$\mu$$` with respect to `$$\phi$$`
`$$$
\begin{align*}
  \mu &= \frac{p_k - p_{k+1}}{\textrm{dp3d}_{\textrm{int}, k}} \\
      &= \frac{ \frac{R_d T_k \textrm{dp3d}_k }{\Delta \phi_k} - \frac{R_d T_{k+1} \textrm{dp3d}_{k+1} }{\Delta \phi_{k+1}}}{\textrm{dp3d}_{\textrm{int}, k+1}} 
\end{align*}
$$$`
and thus
`$$$
\begin{align*}
 \partial_{\Delta \phi_k} \mu &= -\frac{p_k}{\textrm{dp3d}_{\textrm{int}, k+1}} [\Delta \phi_{k}]^{-1}
\end{align*}
$$$`