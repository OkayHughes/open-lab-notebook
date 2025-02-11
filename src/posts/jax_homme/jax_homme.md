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
* Internal grid is constructed 


### Todo:
* Create topology and gridgen :((
* Create structs 
* Implement metric terms + quadrature
* Implement boundary exchange/DSS
* Verify boundary exchange/DSS on sphere
* implement derivatives
* Implement compute_and_apply_rhs for sweqx. 


### Gridgen notes:
* Ordering within a reference element is 
```
      E1
   [v1  v2]
E2 [      ] E3
   [v3  v4]
      E4
```
* An unstructured grid is a set of pairs `$$( (\textrm{pos}_1, \textrm{pos}_2, \textrm{pos}_3, \textrm{pos}_4), ((\textrm{elem}_{E_1},  \textrm{vert id}_{v_1}, \textrm{vert id}_{v_2} ), \ldots, (\textrm{elem}_{E_4},  \textrm{vert id}_{v_3}, \textrm{vert id}_{v_4} ))) $$`
where `$$\textrm{pos}_i $$` are specified as lat-lon points on the sphere.
* Set of transformations is `$$[-1, 1]^2 \mapsto \textrm{Cube} \mapsto \mathbb{S}^2$$`
* Converting this into metric terms for the sphere requires mapping the GLL points in the reference grid to the sphere and taking the product of the consequent Jacobians.
  * Requires DSS of metric terms, as mappings from reference element to cube often results in coincident points having different Jacobian values.
* Standard quasi-homogeneous cube has topology (assuming dice labeling) of 

