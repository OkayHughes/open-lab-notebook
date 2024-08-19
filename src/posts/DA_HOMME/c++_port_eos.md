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

Thankfully 
<details>
  <summary>Invocations of function</summary>
<pre>
cxx/CaarFunctorImpl.hpp-605-        const bool ok1 =                                                                                                                                                        
cxx/CaarFunctorImpl.hpp:606:        m_eos.compute_pnh_and_exner(kv,                                                                                                                                         
cxx/CaarFunctorImpl.hpp-607-                                    Homme::subview(m_state.m_vtheta_dp,kv.ie,m_data.n0,igp,jgp),                                                                                
                                                                                                                                                                                                          
cxx/ForcingFunctor.hpp-309-                                                                                                                                                                                 
cxx/ForcingFunctor.hpp:310:      // The hydrostatic pressure in compute_pnh_and_exner in EOS is only used                                                                                                   
cxx/ForcingFunctor.hpp-311-      // for the theta_hydrostatic_mode case. So only compute it then                                                                                                            
                                                                                                                                                                                                         
cxx/ForcingFunctor.hpp-320-      } else {                                                                                                                                                                   
cxx/ForcingFunctor.hpp:321:        m_eos.compute_pnh_and_exner(kv,vtheta,phinh,pnh,exner);                                                                                                                 
cxx/ForcingFunctor.hpp-322-      }     

cxx/EquationOfState.hpp-71-  KOKKOS_INLINE_FUNCTION
cxx/EquationOfState.hpp:72:  bool compute_pnh_and_exner (const KernelVariables& kv,
cxx/EquationOfState.hpp-73-                              const VThetaProvider& vtheta_dp,

cxx/EquationOfState.hpp-93-      if (nerr) return;
cxx/EquationOfState.hpp:94:      compute_pnh_and_exner(vtheta_dp(ilev), exner(ilev), pnh(ilev), exner(ilev));
cxx/EquationOfState.hpp-95-    }, nerr);

cxx/EquationOfState.hpp-104-  KOKKOS_INLINE_FUNCTION
cxx/EquationOfState.hpp:105:  static void compute_pnh_and_exner (const Scalar& vtheta_dp, const Scalar& dphi,
cxx/EquationOfState.hpp-106-                                     Scalar& pnh, Scalar& exner) {

cxx/EquationOfState.hpp-157-  //       p is computed using dp from pnh, this will be the discrete inverse of
cxx/EquationOfState.hpp:158:  //       the compute_pnh_and_exner method.
cxx/EquationOfState.hpp-159-  KOKKOS_INLINE_FUNCTION static

cxx/Diagnostics.hpp-194-      } else {
cxx/Diagnostics.hpp:195:        m_eos.compute_pnh_and_exner(kv,Homme::subview(vtheta_dp,igp,jgp),
cxx/Diagnostics.hpp-196-                                       Homme::subview(phi_i,igp,jgp),

cxx/DirkFunctorImpl.hpp-576-          if (vtheta_dp(k,i)[s] < 0 || dphi(k,i)[s] > 0) ok = false;
cxx/DirkFunctorImpl.hpp:577:        EquationOfState::compute_pnh_and_exner(
cxx/DirkFunctorImpl.hpp-578-          vtheta_dp(k,i), dphi(k,i), pnh(k,i), exner(k,i));
</pre>
</details>



