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
portion of deformation. This motivates the implementation of 

