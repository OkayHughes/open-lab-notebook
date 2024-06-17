---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: viscoelastic treatment
layout: layouts/post.njk
---

This attempt at this project is founded on the belief that behavior nearer to the glass transition temperature
is most important for the simulations we want to perform.

Combined with work like [this](https://bleyerj.github.io/comet-fenicsx/tours/nonlinear_problems/linear_viscoelasticity_jax/linear_viscoelasticity_jax.html),
this should allow us to implement a rapid prototype in Jax+Fenics, where we can use
automatic differentiation of the constitutive update with respect to input parameters 
to do the Newton update step. 

We start by working through the constitutive equation and volume relaxation given in 
[this article](https://www.sciencedirect.com/science/article/pii/S0045794910001264)
and [this thesis](https://backend.orbit.dtu.dk/ws/portalfiles/portal/5433989/Tempered+Glass.pdf).
This approach splits the glass-like behavior into two components: thermo-rheologically simple (TR) viscoelasticity
and structural volume relaxation. 
TR behavior boils down to a generalized Maxwell model
and adequately describes the response to external loads around the working point `$$T_w$$` of the glass.
The structural volume relaxation describes the processes in glassblowing that implicitly lead to brittle fracture
either on the pipe or in the annealer. 
Our initial implementation will solely describe the TR behavior, which would be a qualitatively satisfying 
(though slightly mathematically incorrect) description of glass if we artificially clamp `$$T > T_g$$` 
(`$$T_g$$` is an empirical "glass transition temperature" used in the ceramic+glass literature).










