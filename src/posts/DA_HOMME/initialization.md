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










### misc garbage
and we integrate (assume no surface topo for the moment) to find
`$$$
\begin{align*}
  (\hat{r}^2 \phi - \hat{r}_{\textrm{sfc}}^2 \phi_{\textrm{sfc}}) &= -\int \frac{R_d T}{p} \pder{}{\eta} \left[\int g\hat{r}^2  \rho  \intd{z} \right]\intd{\eta} \\
    &= \left[\frac{R_d T}{p} \int g\hat{r}^2  \rho  \intd{z} \right]_{\textrm{sfc}}^{\eta}\intd{\eta} - \int \pder{}{\eta} \left[ \frac{R_d T}{p} \right] \cdot \pder{}{\eta} \left[\int g\hat{r}^2  \rho  \intd{z} \right]\intd{\eta}
\end{align*}
$$$`


Other relevant constraints:
`$$$
\int_{\textrm{level}} \rho g \intd{z} = \textrm{dp3d}
$$$`
`$$p_s = \sum_i \textrm{dp3d}$$`