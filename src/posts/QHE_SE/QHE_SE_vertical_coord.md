---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Quasi-hydrostatic CAM-SE
  key: QHE-SE Dry Vertical Coordinate
layout: layouts/post.njk
---

Here we denote `$$m^{[l]} = \frac{\rho^{[l]}}{\rho^{[d]}}$$`, with `$$l \in \mathcal{L}_{\textrm{all}} \equiv \{d, wv, cl, ci, rn, sw\}$$`.

We let
`$$$
\begin{align*}
  \mathcal{L}_{\textrm{water}} = \{wv, cl, ci, rn, sw\}\\
  \mathcal{L}_{\textrm{cond}} = \{cl, ci, rn, sw\}
\end{align*}
$$$
`

The moist (physical) density is then given by
`$$$ \rho = \rho^{[d]} \left(\sum_{l \in \mathcal{L}_{\textrm{all}}} m^{[l]} \right) $$$`

No changes have been made thus far, as these are physical definitions.
## IGL + `$$T_v$$`

The IGL governs the gaseous components, not the condensates! 
The most general governing law for the dry species reads as `$$p^{[d]} V^{[gas]} = N^{[d]} k_B T $$`,
which gets rewritten in typical atmospheric science fashion as
`$$$
p^{[d]} V^{[gas]} - V \rho^{[d]} R^{[d]} T
$$$`
with an analogous equation for `$$p^{[wv]}$$`. We make the assumption that `$$ V = V^{[gas]}$$`, 
by virtue of assuming that condensate species are incompressible and take up negligible volume.
We end up with
`$$$
p = \left(\rho^{[d]}R^{[d]} + \rho^{[wv]} R^{[wv]}\right)T
$$$`

This gets rewritten (letting `$$\varepsilon = \frac{R^{[d]}}{R^{[wv]}} $$`) as
`$$p = \rho R^{[d]} \left(\frac{1 + \frac{1}{\varepsilon} m^{[wv]}}{\sum_{l \in \mathcal{L}_{\textrm{all}}}} \right) $$`