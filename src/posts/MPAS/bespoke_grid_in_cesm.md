---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Creating a 
  parent: MPAS tutorials
layout: layouts/post.njk
---

## Introduction
A recent version of [the Community Atmosphere Model](https://github.com/ESCOMP/CAM/tree/cam_development)
added limited support for the Model for Prediction Across Scales (MPAS) atmospheric dynamical core.
MPAS is a dynamical core with support for a non-hydrostatic equation set built in. It is based on a C-grid discretization on
Spherical Centroidal Voronoi Tesselation (SCVT) horizontal mesh. As such 
it is designed to support variable resolution grids when it is run in its own codebase.
The CIME infrastructure that makes creating new cases and component sets 
necessarily limits the number of horizontal grid spacings that you can use.

This post is designed to show you how to add a new variable resolution MPAS grid
to CIME.

In order to run this you will regrettably need access to a working standalone 







