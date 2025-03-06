---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Code modifications for stratosphere
  parent: DCMIP 2024
layout: layouts/post.njk
---

The hybrid coordinates for the proposed gravity wave test case are located at `/glade/u/home/owhughes/homme_levels/hot_equal`.
88 levels corresponds to a maximum 800m grid spacing, 120 levels is 400m, and 207 levels is 200m.

The HOMME initialization script containing the modifications for the stratosphere is located at `/glade/u/home/owhughes/homme_levels/dcmip2016-baroclinic.F90`.
The three additional parameters are located at line 89.
`lapse_strat =-0.005d0 ` is the nominal lapse rate in the stratosphere, `strat_start = 20d3` is the geometric height at which the stratosphere starts,
and `T_weight = 0.5d0` is the weight factor for the Skamarock modification to the base state. Because we have been running shallow-atmosphere simulations, I have so far left it as `0.5`, which is the default version of the test case described in our paper.
Setting `T_weight=0.8d0` was used in the Deep-atmosphere MPAS paper. If we decide to simulate on a full-size earth, then this modification isn't needed at all!

The remaining changes in the file are:
* Line 189: `T0 =  (T_weight * T0E + (1.0d0 - T_weight) * T0P)` (Skamarock modification)
* Line 352: `T0 =  (T_weight * T0E +(1.0d0 - T_weight)* T0P)` (Skamarock modification)
* Line 476: `T0 = (T_weight * T0E + (1.0d0 - T_weight) * T0P)` (Skamarock modification)
* Line 478: `constAA = 1.d0 / lapse_strat` (Constant used in stratospheric temperature)


