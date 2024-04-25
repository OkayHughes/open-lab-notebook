---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Running Held-suarez on a reduced-radius earth
layout: layouts/post.njk
---
DCMIP2016 steady-state initialization to (hopefully) speed up spinup
```
  REAL(8), PARAMETER ::               &   
       T0E        = 310.d0     ,      & ! temperature at equatorial surface (K)
       T0P        = 240.d0     ,      & ! temperature at polar surface (K)
       B          = 2.d0       ,      & ! jet half-width parameter
       K          = 3.d0       ,      & ! jet width parameter
       lapse      = 0.001d0             ! lapse rate parameter

```

We will use a reduction of `$$r=a/10$$` (Consistent with smallest earth used in Yessad and Wedi (2009)). 
Reduction of lapse rate from 0.005 to 0.001 K/m is to address static instability observed in Skamarock DA MPAS paper.


Output plan:
* u, v, w
* T, p, geo

Output frequency: every 6 hour.


## idea: adapt hybrid to small earth DA

Assume reference column with known `$$T(z)$$` (I'll assume `$$T(z) = 273 K - 0.005 \textrm{ K m}^{-1} \cdot z$$`). 
Assume that the atmosphere is quasi-hydrostatic, `$$$ \pder{p}{z} = -\rho g \implies \log(p/p_s) = - \int \frac{g}{R_d T} \intd{z} $$$`
which we calculate by quadrature and invert via rootfinding 

Given reference interface values for `$$\eta_i, A_i, B_i$$`, we use the fact that `$$A_i + B_i = \eta_i $$`,
then we set `$$\eta'_{K+0.5} = \eta'_{K+0.5}$$`, then set `$$$\frac{(\eta'_{K-0.5} -  \eta'_{K+0.5})}{\hat{r}^2(\eta'_K)} = \eta_{K-0.5} -  \eta_{K+0.5}$$$`


