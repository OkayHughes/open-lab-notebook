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




# Getting integration tests working on GL

The `make test` tests do compare C++ and F90 executables! However, "make all" fails seemingly on every commit I've tried, 
including `maint-1.2`, `maint-2.0`, `maint-3.0`, as well as the original commit that DA HOMME branched from. 
Therefore, the subset of executables needed to run the case must be calculated.
From cmake output, we find that the command should be something like
```
make -j8 swtcA swtcB baroC baroCam baroCam-acc theta-l-nlev20 theta-l-nlev20 preqx-nlev30-interp theta-l-nlev30 tool-nlev26 theta-l-nlev10-native preqx-nlev10-native  theta-l-nlev20-native preqx-nlev10-native-kokkos theta-l-nlev30-kokkos theta-l-nlev20-native-kokkos theta-l-nlev10-native-kokkos preqx-nlev26 preqx-nlev26-kokkos preqx-nlev72 preqx-nlev72-kokkos preqx-nlev72 preqx-nlev72-kokkos theta-nlev128 theta-nlev128-kokkos
```
