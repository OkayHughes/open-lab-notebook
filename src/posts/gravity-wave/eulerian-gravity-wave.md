---
title: Using the CAM Eulerian dynamical core to explore the 2MGW
date: 2021-08-30
tags:
  - posts
  - gravity_wave
layout: layouts/post.njk
---

The Eulerian Spectral dycore in [CAM](https://www.cesm.ucar.edu/models/atm-cam/)
is one of the most computationally efficient ways of solving the primitive equations of motion
for atmospheric flows. 

However, it has several important design considerations
that make it useful for studying the gravity wave that's been giving us so much trouble.
Firstly, it is formulated using Temperature in `$$ ^\circ K $$`. The second is that 
there is no implicit representation of diffusion and it must be added as a namelist parameter.
This allows us to test whether decreasing the strength of horizontal diffusion prevents the wave from being damped.


### Ensuring that the signature is present in the T341 resolution runs.


