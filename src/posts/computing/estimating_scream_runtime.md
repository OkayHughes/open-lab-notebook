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
  * The compute cost of advancing one "time step" (time step will be a shorthand for everything that happens between physics updates.)





