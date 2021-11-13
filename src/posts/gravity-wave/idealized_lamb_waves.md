---
date: 2021-08-30
tags:
  - posts
  - gravity_wave
eleventyNavigation:
  key: Deriving a minimal model of the topography-induced lamb wave
  parent: The two-mountain gravity wave
layout: layouts/post.njk
---



First I'm trying to derive a steady state with extremely benign properties (i.e. use the usual base state
but set `$$ T_0 = T_E = T_P = 270 \mathrm{K} $$`.)

In `ic_baroclinic.F90` set `T0E = T0P = 270.0_r8`, and set `moistq0 = 1.0e-12_r8` (not changing the moisture coefficient
caused mild grid-scale static instability in the horse (?) latitudes).
Put it in an oven preheated to around 36 PE for 5 minutes.


This seems to result in an extremely benign atmosphere with no flow at all

## Adding topography back in

Set `mountain_height=2000.0_r8` in `ic_baroclinic.F90`.

Model runs.



