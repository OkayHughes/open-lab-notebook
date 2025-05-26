---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Energy diagnostics for CESM
layout: layouts/post.njk
---


According to Taylor et al. (2020), the continuum energy budget is defined as
`$$$
\begin{align*}
K + I + P \\
K \equiv \frac{1}{2} \pder{\pi}{s} \boldsymbol{v}^2 \\
I \equiv c_p \Theta_v \Pi - \pder{\pi}{s}\frac{1}{\rho}p + p_{\textrm{top}} \phi_{\textrm{top}} \\
P \equiv \frac{\pi}{s} \phi
\end{align*}
$$$`

If we assume that this code will always be invoked as a column integral, then 
`$$$
\begin{align*}
     \int p \pder{\phi}{s}   \intd{s} - \frac{\p_{\textrm{top}}}{\hat{r}^2} \phi_{\textrm{top}} = \pder{p}{s} \phi 
$$$`

Note: bottom boundary does not disappear outside of time derivative!
