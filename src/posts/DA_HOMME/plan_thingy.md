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
How does that work? Newton's law of gravitation gives us `$$F_{m_1,m_2} = G\frac{m_1m_2}{r^2} $$` Therefore the acceleration for `$$ m_1 $$` is `$$ Gm_2 (R_0 + z)^{-2} $$`

