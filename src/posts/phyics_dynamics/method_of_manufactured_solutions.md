---
date: 2021-08-31
tags:
  - posts
  - directory
eleventyNavigation:
  key: Method of manufactured solutions
  parent: Physics Dynamics Coupling
layout: layouts/post.njk
---
[Inspiration](https://onlinelibrary.wiley.com/doi/abs/10.1002/fld.660)

Idea:
* Take continuum function space (space + time). Ensure obeys boundary conditions (maybe hard?).
* Posit equations of motion (maybe plus hyperviscosity?).
* Posit several solution fields from continuum function space.
* Derive forcing terms necessary to make that solution a steady state. 
* Give dynamics interface to sample with arbitrarily high spatiotemporal frequency. 

This proves code correctness (are we solving the equations that we want to solve?).


Possibilities: take high res atmosphere runs with diabatic forcing, project into continuum basis (e.g. 5 days of high-res amip run). Realistic-ish atmosphere with forcing term backed out by projection. 