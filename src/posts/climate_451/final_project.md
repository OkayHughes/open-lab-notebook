---
date: 2021-08-30
tags:
  - posts
  - climate_451
eleventyNavigation:
  key: Climate 451 Final Project
layout: layouts/post.njk
---

## Purpose

In this project I will examine the (mildly nonlinear) behaviour of flows over complex topography. 
Special attention will be paid to the behaviour as steepness of topography increases to infinity.


## Mathematical prerequisites

We start with the equation from [Long 1953](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.2153-3490.1953.tb01035.x)
for stratified flow over a mountain in the absence of friction, described by a streamfunction `$$ \Psi $$`
`$$$ \nabla^2 \Psi  + \frac{\partial_ze}{e} \left[ \partial_z \Psi  - \frac{1}{2}\left\|\nabla \Psi \right\|^2\right] + \frac{N^2}{U^2} \Psi = 0 \qquad \mathsection \textrm{Nonlinear}$$$`
Where `$$ e = (1/2) \rho_0 U^2$$`, and `$$U = U(z) $$` is the background flow away from the mountain.

We make the following assumptions following Lin: 
- `$$ \Psi $$` has no deflection far upstream of the mountain (i.e. streamlines are horizontal)
- `$$U(z) \equiv C $$` and `$$N(z) \equiv C $$`
- The atmosphere is Boussinesq. 

Under these assumptions, the 