---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Ugh
layout: layouts/post.njk
---

Let `$$\eta_{\textrm{deep}}, \eta_{\textrm{shallow}}$$` be the deep and shallow mass coordinates,
respectively. Analytic test cases, as well as, e.g., initializing from data,
specify an invertible map `$$ \eta_{\textrm{shallow}} \mapsto z$$`. 
When we read `$$\eta$$` values from a file in DA HOMME, these are `$$ \eta_{\textrm{deep}}$$` values.
We define the new mass coordinate such that
`$$$
\frac{\partial \pi}{\eta} = \rho g_0 \textrm{ becomes } 
$$$`


In [this article](https://www.ecmwf.int/sites/default/files/elibrary/2011/13179-hydrostatic-and-non-hydrostatic-global-model-ifsarpege-deep-layer-model-formulation-and.pdf)

Define `$$A_F(\eta), B_F(\eta)$$` (where `$$F$$` could stand for something like "file").
We seek modified internal model profiles `$$A_M(\eta), B_M(\eta)$$` that are suitable for small-planet
simulation.

In their parlance `$$\tilde{\pi}$$` is the deep-atmosphere column-integrated mass
and `$$\pi$$` is the shallow-atmosphere column-integrated mass. 



