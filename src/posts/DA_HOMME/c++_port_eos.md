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



Todo:
* `compute_phi_i` called in remap. Uses old EOS
* 





