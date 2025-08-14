npd---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  key: bfb transport
  parent: Porting DA HOMME to C++
layout: layouts/post.njk
---

### Porting changes to transport code

changes in:
* `components/homme/src/share/prim_driver_base.F90`
* `components/homme/src/share/sl_advection.F90`

Routines that should ideally be tested:
* `calc_trajectory`
* `set_tracer_transport_derived_values`
* `applyCAMforcing_tracers`




* Are there EAMXX integration tests??
