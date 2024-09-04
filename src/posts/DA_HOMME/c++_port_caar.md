npd---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  key: CaarFunctorImpl update
  parent: Porting DA HOMME to C++
layout: layouts/post.njk
---


## updating Caar
run() outlines the sequence of policies
  * m_policy_pre
  * m_plicy_post
  

  
### m_policy_pre
TagPreExchange

List of changes:
  * div_vdp
    * Need to access multiple levels phinh_i
    * Use ColumnOps::compute_midpoint_values
  * compute_scan_quantities:
    * divergence of pi is used only for diagnostic omega. Ignore for now
  * compute_interface_quantities
    * Nothing to do 
  * compute_vertical_advection
    * Ignoring eulerian vcoord for now
  * compute_accumulated_quantities
    * Nothing to do, all eulerian and diagnostics *(if diagnostics tested, then oops)*
  * compute_w_and_phi_tens
    * Modify gradient -> done
    * Add w tendency term
  
Adding fcorcos:
  * src/share/cxx/ElementsGeometry.cpp
  * src/theta-l_kokkos/cxx/cxx_f90_interface_theta.cpp
  * src/theta-l_kokkos/cxx/CaarFunctorImpl.hpp
    
  
  
  
### m_policy_post
  * TagPostExchange
