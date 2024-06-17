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

