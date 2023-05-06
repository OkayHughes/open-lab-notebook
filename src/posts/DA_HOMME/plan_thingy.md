---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Plan March 2023
layout: layouts/post.njk
---


Current plan for Deep Atmosphere HOMME:

* By next week:
  * Verify derivation in MT overleaf document myself (Use python notebook with toy coefficients/profiles to _ensure_ that there aren't typos)
  * Verify lines in `prim_advance_mod.F90` which correspond to each of these.
  * Optional: Identify lines in `EOS.f90` which need to be modified, and list of variables that might accidentally assume EOS elsewhere in code
  * No actual modifications
* Probably can be done by next month?

* Staniforth/white:
  * Need to separate out centrifugal force term in both HPE and 3d Euler.
  * But: I'm already modifying the equations of state. Can just add a correction term to `prim_advance_mod.F90`



# Breadcrumb: How is hydrostatic pseudodensity calculated?

There's something funky in the calculation of `$$\pi(s)$$`. Do the definitions in MT's document account for spatial variation in `$$g$$`?

I'm gonna have to look really foolish because theres a simplified form for `$$g$$` that you can derive. 
How does that work? Newton's law of gravitation (assuming a sufficiently nice earth) gives us `$$F_{m_1,m_2} = G\frac{m_1m_2}{r^2} $$` 
Therefore the acceleration for `$$ m_1 $$` is 
`$$$ 
\begin{align*}
  g = Gm_2 (R_0 + z)^{-2} &= \frac{Gm_2}{R_0^2} \cdot \left(\frac{R_0}{R_0+z}\right)^{2} \\
  &= g_0 \left(\frac{R_0}{R_0+z} \right)^2
\end{align*}
$$$`
and so defining `$$ \hat{r} = \frac{R_0 + z}{R_0}$$` we find `$$$ g = g_0 \hat{r}^{-2}.$$$`

### Hydrostatic pressure in shallow atmosphere
We define 
`$$$
\begin{align*}
\pi_s(z) &= p_{\tm{top}} + \int_{z}^{z_{\tm{top}}} \rho g \intd{z}  \\
&\stackrel{(1)}{=}p_{\tm{top}}  \int_{z}^{z_\tm{top}} \rho g_0 \intd{z} \\
&= p_{\tm{top}} - \int_{z}^{z_\tm{top}} \intd{p}\\
&=  p_{\tm{top}} - (p_{\tm{top}} - \pi(z))\\
\end{align*}
$$$`
where (1) holds only under the shallow atmosphere assumption. Done this a hundred times. 

### Hydrostatic pressure in deep atmosphere
`$$$
\begin{align*}
\pi_d(z) &= p_{\tm{top}} + \int_{z}^{z_{\tm{top}}} \rho g \intd{z} \\
&= p_{\tm{top}} + \int_{z}^{z_{\tm{top}}} \rho g \intd{z} \\
\end{align*}
$$$`



