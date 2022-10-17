---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Debuggin potential vorticity in E3SM
  parent: E3SM
layout: layouts/post.njk
---


## Choosing actual functions for PV formulation:

We use the folliwng formulation of potential vorticity:

`$$$ \mathrm{PV} = - \frac{g}{p_0 \partial_\eta a + p_s \partial_\eta b } \left[ \left(\zeta_\eta + f \right) \partial_\eta \theta - \frac{1}{\overline{r} \cos \varphi} \left(\partial_\eta v \right) \left(^\eta\partial_\lambda \theta\right) + \frac{1}{\overline{r}} (\partial_\eta u)\left(^\eta\partial_\varphi \theta\right) \right] $$$`


with `$$ \zeta_\eta = \frac{1}{\overline{r}\cos\varphi} \left((^\eta \partial_\lambda v) - (^\eta \partial_\varphi u\cos \phi ) \right) $$`


## Pitfalls of comparing against lat-lon grids:

Assuming I calculate the above quantity correctly, then `$$\partial u $$` and `$$\partial v $$` are are calculated 
to machine precision. That is, assuming we have an internal (numerical) state `$$\mathbf{u, v}_{mijk} $$` where `$$m$$`
indexes element ID, `$$i,j $$` index the tensored GLL points within an element, and `$$k$$` indexes level.