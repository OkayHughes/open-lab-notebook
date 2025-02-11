---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: jax homme
layout: layouts/post.njk
---

Parent post for the jax homme project.

### Notes:
* Prognostic equations use strong derivatives, but Laplacian is calculated weakly in diffusion, even in `sweqx`.
* Element access must be order-agnostic outside of boundary exchange routines!



### Todo:
* Create structs 
* Implement metric terms + quadrature
* Implement boundary exchange/DSS
* Verify boundary exchange/DSS on sphere
* implement derivatives
* Implement compute_and_apply_rhs for sweqx. 

