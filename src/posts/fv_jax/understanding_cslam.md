---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: fv jax
  key: Understanding cslam
layout: layouts/post.njk
---


## Major approximations:
* Construction of departure/arrival cells assume both are quadrilaterals. 


## General layout
* Construct Eulerian subgrid density



## Specifics
`$$\der{d}{dt} \int_{A(t)} \psi \intd{A} = 0 $$` (this equation is kind of ill posed as is), but expresses the continuity equation.

Let `$$A_k$$` be `$$A(t+\Delta t)$$` and `$$a_k$$` be `$$A(t)$$`, as in this algorithm we use backwards trajectories. Let `$$\Omega$$` be the total domain, decomposed as `$$ \bigsqcup_{k=1}^n a_k$$`. `$$\Delta t$$` must not be so long that trajectories cross.

Key to this method is the overlap `$$ a_{kl} = a_k \cap A_l$$`, with `$$ l =1,\ldots,L_k$$`, and at worst `$$1 \leq L_k \leq N$$`, indicating that for pathological flows there will be a worst-case `$$n^2$$` term, but in practice this would be highly unlikely.

Note: as the area `$$a_k$$` travels with the flow, there is no flux across element boundaries, giving the highly concise expression for discretized transport
`$$$\overline{\psi}_k^{n+1}\Delta A_k = \overline{\psi}_k^{*^n} \delta a_k $$$`, with the left hand side being quantities for arrival and the rhs being departure. `$$\overline{\phi}$$` is cell-averaged density.

We defer the properties necessary to make the subgrid Eulerian representation mass conservative until later. If we have such a reconstruction `$$f_l(x, y)$$`, then we get
`$$$
\overline{\psi}_k^{*^n} = \frac{1}{\delta a_k} \sum_{l=1}^{L_k} \iint_{a_{kl}} f_l(x, y) \intd{A},
$$$`
where we note that the intersections `$$ a_{kl}$$` each individually experience no flux across region, so what is happening is that the cell averaged density in each `$$a_{kl}$$` is computed, advected without flux, and then "mixed" upon arrival in `$$A_l$$`.

We therefore find the natural condition on  `$$f_l$$` to ensure global mass conservation to be:
`$$$
\iint_{A_l} f_l(x, y) = \overline{\psi}_l \Delta A_l,
$$$`
as this ensures that the decomposition above faithfully parcels out all of the mass in the arrival cell.

We now make the (significant?) approximation that departure cells are quadrilateral. Even under this approximation, polygonal intersections are a pain in the ass.

### Recall: Green's theore,
