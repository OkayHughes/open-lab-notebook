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
I \equiv c_p \Theta_v \Pi - \pder{\pi}{s}\frac{1}{\rho}p + p_{\textrm{top}} \phi_{\textrm{top}} \equiv c_p \Theta_v \Pi + \pder{}{s}\left[\hat{r}^2 p \right] \phi  + \pi_{\textrm{top}} \phi_{\textrm{top}}  \\
P \equiv \pder{\pi}{s} \phi
\end{align*}
$$$`

Using the equation of state `$$\pder{\phi}{s} = - \hat{r}^{-2} R_d \Theta_v \frac{\Pi}{p} \implies \pder{\pi}{s} = -\pder{\phi}{s} \rho \hat{r}^2 $$`,
we can write `$$-\left(\rho^{-1}\pder{\pi}{s} \right) p = p\hat{r}^2 \pder{\phi}{s}  $$`
`$$$
\begin{align*}
     \int p \hat{r}^2 \pder{\phi}{s} \intd{s} - \pi_{\textrm{top}} \phi_{\textrm{top}} &= \left[ p \hat{r}^2 \phi \right]_{\textrm{bottom}}^\textrm{top} - \int \pder{}{s} \left( \hat{r}^2 p \right) \phi \intd{s} + \pi_{top} \phi_{\textrm{top}} \\
     &= p_s \hat{r}^2_s \phi_s - \frac{\pi_\textrm{top}}{\hat{r}^2_{\textrm{top}}} \hat{r}^2_{\textrm{top}} \phi_{\textrm{top}}- \int \pder{}{s} \left( \hat{r}^2 p \right) \phi \intd{s} + \pi_{\textrm{top}}  \phi_{\textrm{top}} \\
     &= p_s \hat{r}^2_s \phi_s - \int \pder{}{s} \left( \hat{r}^2 p \right) \phi \intd{s}
\end{align*} 
$$$`

Note: bottom boundary does not disappear outside of time derivative!
