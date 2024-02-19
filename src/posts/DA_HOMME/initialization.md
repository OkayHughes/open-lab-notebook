---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Non-local initialization
layout: layouts/post.njk
---

The strong form of the EOS is 
`$$$
\begin{align*}
 \partial_\eta[\hat{r}^2 \phi] &= - R_d \theta \textrm{ dp3d } \frac{\Pi}{p} \\
  &= -\frac{R_d T}{p} \pder{}{\eta} \left[ \int g\hat{r}^2  \rho  \intd{z} \right] \\
\end{align*}
$$$`
and we integrate (assume no surface topo for the moment) to find
`$$$
  (\hat{r}^2 \phi - \hat{r}_{\textrm{sfc}}^2 \phi_{\textrm{sfc}}) = -\int \frac{}{} \intd{\eta}
$$$`