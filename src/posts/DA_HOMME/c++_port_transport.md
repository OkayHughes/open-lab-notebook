---
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
make -j8 swtcA swtcB baroC baroCam baroCam-acc theta-l-nlev20 theta-l-nlev20 preqx-nlev30-interp theta-l-nlev30 tool-nlev26 theta-l-nlev10-native preqx-nlev10-native  theta-l-nlev20-native preqx-nlev10-native-kokkos theta-l-nlev30-kokkos theta-l-nlev20-native-kokkos theta-l-nlev10-native-kokkos preqx-nlev26 preqx-nlev26-kokkos preqx-nlev72 preqx-nlev72-kokkos preqx-nlev72 preqx-nlev72-kokkos theta-nlev128 theta-nlev128-kokkos dirk_ut caar_ut compose_ut eos_ut baseline cprnc
```

The issue in cprnc is due to improper preprocessor defines that result in the preprocessor variable indicating the integer datatype not being defined. 
These problems occur because there are spaces before the `#` character. 

The command to run an individual test is `ctest -R ${testname}`, and `make baseline` generates reference files to ensure that your changes didn't break anything important.
When `cmake` is called in a working directory where the test suite will be run, use `-DUSE_NUM_PROCS=24` so regression tests will run faster.


# How to make DA HOMME mergeable
* Generate baseline test results from commit that `og/da` branch branched off from
* Ensure that `-DWITH_DA=OFF` HOMME passes regression tests
* Ensure that cxx/f90 comparison tests are bfb

Comparison tests:
```
-- Creating cxx-f90 comparison test preqx-nhgw_cxx_vs_f90
-- Creating cxx-f90 comparison test preqx-nhgw-slice_cxx_vs_f90
-- Creating cxx-f90 comparison test thetah-sl-test11conv-r0t1-cdr30-rrm_cxx_vs_f90
-- Creating cxx-f90 comparison test thetanh-moist-bubble_cxx_vs_f90
-- Creating cxx-f90 comparison test thetanh-dry-bubble_cxx_vs_f90
-- Creating cxx-f90 comparison test thetah-nhgw_cxx_vs_f90
-- Creating cxx-f90 comparison test thetanh-nhgw_cxx_vs_f90
-- Creating cxx-f90 comparison test thetah-nhgw-slice_cxx_vs_f90
-- Creating cxx-f90 comparison test thetanh-nhgw-slice_cxx_vs_f90
-- Creating cxx-f90 comparison test preqx-nlev26-dry-r0-samenu-consthv-lim8-q1-ne2-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test preqx-nlev72-dry-r3-diffnu-consthv-lim9-q6-ne2-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test preqx-nlev72-moist-r3-samenu-tensorhv-lim9-q1-ne2-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-f1-tt10-hvs1-hvst0-r2-qz10-nutopoff-GB-sl-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-fhs1-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-fhs2-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-fhs3-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-fdc12-test21-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-fdc12-test22-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-fdc12-test3-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-f0-tt5-hvs1-hvst0-r3-qz1-nutopoff-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-f1-tt5-hvs1-hvst0-r3-qz1-nutopoff-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-f1-tt5-hvs1-hvst0-r0-qz1-nutopoff-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-f1-tt10-hvs3-hvst0-r3-qz1-nutopoff-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-f1-tt10-hvs3-hvst5-r3-qz1-nutopon-ne2-nu3.4e18-ndays1_cxx_vs_f90
-- Creating cxx-f90 comparison test theta-f1-tt10-hvs1-hvst0-r2-qz10-nutopoff-GB-ne2-nu3.4e18-ndays1_cxx_vs_f90
```
