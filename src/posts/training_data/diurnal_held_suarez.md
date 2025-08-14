---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Training data
  key: Diurnal Held Suarez
layout: layouts/post.njk
---

The stock Held-Suarez uses tendencies like
`$$$
\begin{align*}
\pder{T}{t} &= k_T (T_{\textrm{ref}}(p) - T) \\
\pder{\boldsymbol{v}_h}{t} &= -k_v(p) \boldsymbol{v}_h 
\end{align*} $$$`

This means that Ertel's Potential Vorticity and potential temperature 
are not conserved, as the flow is not adiabatic. 
For the purpose of examining the physicality of the flows predicted by ML 
weather models, one possible way of quantitatively diagnosing aphysical predictions is by comparing these two conserved quantities under adiabatic flow. The benefit of HS is that a model run can be simulated for decades and develop a statistically stationary climate. 


