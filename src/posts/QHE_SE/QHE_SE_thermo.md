---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Quasi-hydrostatic CAM-SE
  key: QHE-SE thermo
layout: layouts/post.njk
---
A number of things in `src/utils/cam_thermo.F90` need to change in order to create quasi-hydrostatic equilibrium.

The most immediate changes will be to `get_pmid_from_dp` and `get_gz`. We'll possibly need to change `get_rho_dry`, `get_ps`,
and `get_dp`.


This work involves two intermediate steps:
  * Implement QHE in reconstruction of geopotential (This should basically make AAM budget fine)
  * Add `$$\hat{r}^2$$` terms to pseudodensity 