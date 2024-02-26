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

If we assume a Neumann upper boundary condition (i.e., `$$\mu \approx 1$$`) as described elsewhere,
the most obvious way to translate a shallow-atmosphere state described in pressure coordinates is to use
`$$T$$` and some method of calculating _physical_ density `$$\rho$$`, such as `$$p$$` (which is _physical_ pressure) and
the DA HOMME EOS:
`$$$
  p_k = \frac{R_d T_{v, k} \textrm{ dp3d}_k}{\hat{r}^2 \Delta \phi_k} = \frac{R_d \theta_{v, k} \Pi \textrm{ dp3d}_k}{\hat{r}^2 \Delta \phi_k}
$$$`
and I have previously been enforcing this pointwise at model levels starting from the lower boundary where `$$\phi_{K+1}  = \phi_{\textrm{surf}}$$`
and we rootfind on `$$\phi_{k}$$` for `$$k = K, \ldots, 1$$`. 
This results in a very slightly imbalanced vertical structure in the atmosphere. In the DCMIP 2016 steady state test case in ne30 resolution with 30 levels,
this results in initial vertical motion on the order of `$$10^{-3}$$` m/s for around 500 seconds, after which point `$$\mu \equiv 1$$`.
A rough analysis of the change in `$$z$$` is that there is an approximately 100 m adjustment in vertical levels in the uppermost levels of the atmosphere.

My current assumption is that this adjustment is due to the fact that initializing the atmosphere such that 
pressure agrees at model levels does not guarantee that the discrete averaging used to reconstruct
pressure at interfaces, namely
`$$$
  p_{k+\frac{1}{2}} = \frac{(\textrm{dp3d}_k)p_k + (\textrm{dp3d}_{k+1})p_{k+1}}{\textrm{dp3d}_{k} + \textrm{dp3d}_{k+1}}
$$$`
is satisfied. 








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