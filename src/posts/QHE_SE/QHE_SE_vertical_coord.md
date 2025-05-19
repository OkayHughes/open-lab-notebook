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

The partial pressure of dry air (which is strongly decoupled from the mass coordinate, even in )