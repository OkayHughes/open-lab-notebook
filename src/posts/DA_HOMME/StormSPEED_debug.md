---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Why is StormSPEED output garbage?
layout: layouts/post.njk
---

Stormspeed output appears to be garbage. The grid imprinting appears both when physics and dynamics are collocated, as well as when the PG infrastructure is used.
It is present both in interpolated and native output.
In aquaplanet simulations, the edges of the polar panels are clearly present in the output. Inconclusive on whether side panel edges are imprinting in a less visible way. 


## Promising avenues of exploration:
* Examine divergence, gradient, vorticity calculation for test flow field trojan-horsed in via 2016 BW initialization
* Prep scatter plot plotting for diagnostics, especially for `ncol_d` 


## Notes
Working case is `/glade/derecho/scratch/owhughes/StormSPEED_NCAR.ne30pg3_ne30pg3_mg17.QPC7.AQP.is_aqp_garbo/run`

