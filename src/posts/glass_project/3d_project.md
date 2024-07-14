---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Outline of MPM strategy
layout: layouts/post.njk
---

[Paper 1](https://ceramics.onlinelibrary.wiley.com/doi/full/10.1111/jace.16963) 
describes a negligible-deformation constitutive equation for the Burgers model with material parameters 
that are fit based on temperature. The paper makes the statement that
this model is equivalent to a two-term Prony series. My understanding is that 
this means that it is equivalent to a two-component Generalized Maxwell Model.
This intuitiion is confirmed in [Paper 2](https://www.mdpi.com/2311-5521/3/4/69) which derives 
the equivalence and formulates the three-dimensional analogue as a two-component upper-convected maxwell model
(though it notes that basically any objective derivative, e.g. lower oldroyd gives a generalization).
This latter paper introduces a multiplicative plasticity that is very similar to 
the one given in [Paper 3](https://dl.acm.org/doi/10.1145/2786784.2786798).
Both Paper 2 and Paper 3 derive similar energy functionals for the (hyper-) elastic
portion of deformation. This motivates the implementation of [Paper 4](https://dl.acm.org/doi/10.1145/3197517.3201293)
which implements MPM-MLS for a multiplicative plasticity flow rule.

Therefore the project is divided into several phases:
* Implement in numpy the vanilla semi-implicit algorithm from Paper 4 for newtonian fluids with spatially varying viscosity (e.g. WLF) following, e.g., [this tutorial](https://nialltl.neocities.org/articles/mpm_guide)
for temperatures well above the softening point.
* Translate this implementation into jax. 
* Implement thermodynamic solver and pressure split from [Paper 5](https://dl.acm.org/doi/10.1145/2601097.2601176)
* Implement the oldroyd-b (actually upper-convected maxwell model) for temperatures between glass transition and softening point from Paper 3.
* Use the parameters from [Paper 1] to model solidification.


