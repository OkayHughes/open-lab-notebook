---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  key: compute_pnh_and_exner update
  parent: Porting DA HOMME to C++
layout: layouts/post.njk
---


### updating compute_pnh_and_exner

Line 82 in ColumnOps::compute_midpoint_delta(kv,phi_i,exner);
indicates that there is an implementation of the function `compute_pnh_and_exner` taking `phi_i` as a parameter
which contains all necessary info to calculate new EOS. 
This implementation then calls the `compute_pnh_and_exner` taking only `dphi` (hidden in the `exner` variable).


* cxx/EquationOfState.hpp:105
* cxx/DirkFunctorImpl.hpp:577

## DirkFunctorImpl 
* 281: add phi_np1 to method call `pnh_and_exner_from_eos`
* 322: `run_initial_guess` contains pattern for computing scans optimally
* Currently: just use `scan_dphi`, which is horribly inefficient
  

## Debugging notes:
* When division by rhatinvsq_m is disabled, exner test passes. 
  * Three possibilities
  * phi_i in calling code is different between fortran and c++ (fucked up transpose)
  * phi_i indexing in calculation of rhatinvsq_m is 
  * phi_i division in compute_pnh_and_exner? 


Todo:
* Ensure `compute_phi_i` calls in remap are hydrostatic
  * If `compute_phi_i` is comparable to `phi_from_eos` in fortran code
* Update calls to compute_pnh_and_exner
    * 577 in dirk is a PROBLEM
* Update calls to compute_dpnh_dp_i

Debugging notes:
* Let's say you set `phi_i` to 5 in the internal call to compute_pnh_and_exner.
  * 



