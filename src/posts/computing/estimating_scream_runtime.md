---
title: Some slurm hacks
date: 2021-08-31
tags:
  - posts
  - slurm
  - scientific-computing
eleventyNavigation:
  key: SCREAM computational cost?
  parent: Scientific Computing
layout: layouts/post.njk
---

Several people in our research group need to answer the following question:
If you know the cost of running an ESM configuration whose compute time is almost entirely due to the Atmospheric component (e.g., Aquaplanet, SCREAM, etc.)
at nominal 1º resolution, can you compute the cost of running a regionally refined model configuration?

Here are (some of) my starting assumptions:
  * The (compute) cost of advancing one "time step" (time step will be a shorthand for everything that happens between physics updates) does not change with the size of a grid cell.
  * The nominal 1º reference simulation uses a grid partition/load balancing such that the amount of inter-node communication required is comparable to 
  what it will be for the variable resolution run. E.g., a simulation performed with all physics/dynamics work performed within a single node (even if it uses multiple sockets) may be a bad reference cost.
  * The model has been tailored to the target computer such that increasing the number of nodes in a simulation does not cause drastic increases 
  in time spent in MPI calls and, what is possibly more troubling, filesystem and IO calls. 
  * Remapping, e.g. for file output, is a negligible percentage of total runtime.

With that in mind, I think you can (approximately) compute the cost basically by counting elements and accounting for the new time step `$$\Delta t$$`.
One way to do this if you don't yet have a particular grid in mind is by defining some density function over the surface of the earth with units of, e.g., Grid Points/sq km 
that matches the final and integrate over the surface of the earth. For a constant function `$$ f(\cdot, \cdot) = \frac{1}{30} \textrm{Grid Point}~\textrm{km}^{-1}$$`, 

  





