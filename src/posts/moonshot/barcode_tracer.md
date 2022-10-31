---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: barcode tracers
  parent: Moonshot Ideas
layout: layouts/post.njk
---

## Motivation:
Suppose we have a geographically isolated event (say a particular region of equatorial deep convection) and we 
want to ask the question "Which regions of weather, say, up to 14 days ago could have contributed to this?".
If one kept track of the advecting winds at every time step in the last 14 days, initialize a point-source
tracer in the region of interest, and evolve the system backwards in time. Anywhere that had that tracer could 
concievably have contributed to the weather at the point of interest.

Now, this is prohibitively expensive for the usual reasons. So the question is, if we have a 
restart file 14 days before the event of interest (say, a set of grid point locations),
can we initialize a set of tracers that would back out these dependencies? That is,
in data analysis we identify a grid cell of interest and we can back out a "heat map" (which
might be a binary mask) of grid cells. Assume the lag time `$$T $$` is fixed and, for the moment,
there is only one cell with ID `$$i_{\textrm{event}}$$` for which we want to compute this "inversion".


If I'm allowed to have an entirely different "component" which isn't a bolt-on tracer system, then here's a potential 
way to do this with particles:
At each barcode time step, initialize a particle containing a bit-mask with a bit for each horizontal grid cell.
Another design branch here would be to initialize several particles and add an uncertainty parameter `$$ \kappa $$`
that introduces stochasticity to the advection of these particles. Move forward one (dynamics?) timestep,
then take the bitwise or of every particle assigned to a grid cell with the stored "upwind bitmap" for that grid cell.
After `$$n_{\textrm{remap}}$$` timesteps, re-initialize the ensembles of particles 