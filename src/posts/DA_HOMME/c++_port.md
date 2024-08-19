---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Porting DA HOMME to C++
layout: layouts/post.njk
---

Fine grain todo:
* ~~Rework dirk calling interface so code compiles~~
* ~~verify eos does not pass~~
* Determine ColumnOps call to calculate phi_i 

Coarse-grained todo:
* Ensure unit tests failing for DA HOMME
* Identify other unit tests that may be helpful
* Get caar_ut unit test to pass
* get dirk unit test to pass




### updating compute_pnh_and_exner

Line 82 in ColumnOps::compute_midpoint_delta(kv,phi_i,exner);
indicates that there is an implementation of the function `compute_pnh_and_exner` taking `phi_i` as a parameter
which contains all necessary info to calculate new EOS. 
This implementation then calls the `compute_pnh_and_exner` taking only `dphi` (hidden in the `exner` variable).

Thankfully the 
<details>
cxx/EquationOfState.hpp-71-  KOKKOS_INLINE_FUNCTION
cxx/EquationOfState.hpp:72:  bool compute_pnh_and_exner (const KernelVariables& kv,
cxx/EquationOfState.hpp-73-                              const VThetaProvider& vtheta_dp,
--
cxx/EquationOfState.hpp-93-      if (nerr) return;
cxx/EquationOfState.hpp:94:      compute_pnh_and_exner(vtheta_dp(ilev), exner(ilev), pnh(ilev), exner(ilev));
cxx/EquationOfState.hpp-95-    }, nerr);
--
cxx/EquationOfState.hpp-104-  KOKKOS_INLINE_FUNCTION
cxx/EquationOfState.hpp:105:  static void compute_pnh_and_exner (const Scalar& vtheta_dp, const Scalar& dphi,
cxx/EquationOfState.hpp-106-                                     Scalar& pnh, Scalar& exner) {
--
cxx/EquationOfState.hpp-157-  //       p is computed using dp from pnh, this will be the discrete inverse of
cxx/EquationOfState.hpp:158:  //       the compute_pnh_and_exner method.
cxx/EquationOfState.hpp-159-  KOKKOS_INLINE_FUNCTION static
--
cxx/Diagnostics.hpp-194-      } else {
cxx/Diagnostics.hpp:195:        m_eos.compute_pnh_and_exner(kv,Homme::subview(vtheta_dp,igp,jgp),
cxx/Diagnostics.hpp-196-                                       Homme::subview(phi_i,igp,jgp),
--
cxx/DirkFunctorImpl.hpp-576-          if (vtheta_dp(k,i)[s] < 0 || dphi(k,i)[s] > 0) ok = false;
cxx/DirkFunctorImpl.hpp:577:        EquationOfState::compute_pnh_and_exner(
cxx/DirkFunctorImpl.hpp-578-          vtheta_dp(k,i), dphi(k,i), pnh(k,i), exner(k,i));
</details>

