---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Plan November 22
  key: prim_advance_mod.F90
layout: layouts/post.njk
---

<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HAVE_CONFIG_H</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">include</span> <span style="color: #e6db74">&quot;config.h&quot;</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">!  Man dynamics routines for &quot;theta&quot; nonhydrostatic model</span>
<span style="color: #75715e">!  Original version: Mark Taylor 2017/1</span>
<span style="color: #75715e">!  </span>
<span style="color: #75715e">!  2018/8 TOM sponge layer scaling from P. Lauritzen</span>
<span style="color: #75715e">!  09/2018: O. Guba  code for new ftypes</span>
<span style="color: #75715e">!  2018/12: M. Taylor apply forcing assuming nearly constant p </span>
<span style="color: #75715e">!  2019/5:  M. Taylor time-split TOM dissipation and hyperviscsity</span>
<span style="color: #75715e">!  2019/7:  M. Taylor add dp3d limiter to prevent zero thickness layers</span>
<span style="color: #75715e">!</span>
<span style="color: #66d9ef">module </span><span style="color: #f8f8f2">prim_advance_mod</span>

  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">bndry_mod,</span>          <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">bndry_exchangev</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">control_mod,</span>        <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">dcmip16_mu,</span> <span style="color: #f8f8f2">dcmip16_mu_s,</span> <span style="color: #f8f8f2">hypervis_order,</span> <span style="color: #f8f8f2">hypervis_subcycle,&amp;</span>
    <span style="color: #f8f8f2">integration,</span> <span style="color: #f8f8f2">nu,</span> <span style="color: #f8f8f2">nu_div,</span> <span style="color: #f8f8f2">nu_p,</span> <span style="color: #f8f8f2">nu_s,</span> <span style="color: #f8f8f2">nu_top,</span> <span style="color: #f8f8f2">prescribed_wind,</span> <span style="color: #f8f8f2">qsplit,</span> <span style="color: #f8f8f2">rsplit,</span> <span style="color: #f8f8f2">test_case,&amp;</span>
    <span style="color: #f8f8f2">theta_hydrostatic_mode,</span> <span style="color: #f8f8f2">tstep_type,</span> <span style="color: #f8f8f2">theta_advect_form,</span> <span style="color: #f8f8f2">hypervis_subcycle_tom,</span> <span style="color: #f8f8f2">pgrad_correction,&amp;</span>
    <span style="color: #f8f8f2">vtheta_thresh</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">derivative_mod,</span>     <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">derivative_t,</span> <span style="color: #f8f8f2">divergence_sphere,</span> <span style="color: #f8f8f2">gradient_sphere,</span> <span style="color: #f8f8f2">laplace_sphere_wk,&amp;</span>
    <span style="color: #f8f8f2">laplace_z,</span> <span style="color: #f8f8f2">vorticity_sphere,</span> <span style="color: #f8f8f2">vlaplace_sphere_wk</span> 
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">derivative_mod,</span>     <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">subcell_div_fluxes,</span> <span style="color: #f8f8f2">subcell_dss_fluxes</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">dimensions_mod,</span>     <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">max_corner_elem,</span> <span style="color: #f8f8f2">nlev,</span> <span style="color: #f8f8f2">nlevp,</span> <span style="color: #f8f8f2">np,</span> <span style="color: #f8f8f2">qsize</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">edge_mod,</span>           <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">edge_g,</span> <span style="color: #f8f8f2">edgevpack_nlyr,</span> <span style="color: #f8f8f2">edgevunpack_nlyr</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">edgetype_mod,</span>       <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">EdgeBuffer_t,</span>  <span style="color: #f8f8f2">EdgeDescriptor_t,</span> <span style="color: #f8f8f2">edgedescriptor_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">element_mod,</span>        <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">element_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">element_state,</span>      <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">nu_scale_top,</span> <span style="color: #f8f8f2">nlev_tom,</span> <span style="color: #f8f8f2">max_itercnt,</span> <span style="color: #f8f8f2">max_deltaerr,max_reserr</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">element_ops,</span>        <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">state0,</span> <span style="color: #f8f8f2">get_R_star,</span> <span style="color: #f8f8f2">tref_lapse_rate</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">eos,</span>                <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">pnh_and_exner_from_eos,pnh_and_exner_from_eos2,phi_from_eos</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">hybrid_mod,</span>         <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">hybrid_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">hybvcoord_mod,</span>      <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">hvcoord_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">kinds,</span>              <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">iulog,</span> <span style="color: #f8f8f2">real_kind</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">perf_mod,</span>           <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">t_adj_detailf,</span> <span style="color: #f8f8f2">t_barrierf,</span> <span style="color: #f8f8f2">t_startf,</span> <span style="color: #f8f8f2">t_stopf</span> <span style="color: #75715e">! _EXTERNAL</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">parallel_mod,</span>       <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">abortmp,</span> <span style="color: #f8f8f2">global_shared_buf,</span> <span style="color: #f8f8f2">global_shared_sum,</span> <span style="color: #f8f8f2">iam,</span> <span style="color: #f8f8f2">parallel_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">physical_constants,</span> <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">Cp,</span> <span style="color: #f8f8f2">cp,</span> <span style="color: #f8f8f2">cpwater_vapor,</span> <span style="color: #f8f8f2">g,</span> <span style="color: #f8f8f2">kappa,</span> <span style="color: #f8f8f2">Rgas,</span> <span style="color: #f8f8f2">Rwater_vapor,</span> <span style="color: #f8f8f2">p0,</span> <span style="color: #f8f8f2">TREF</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">physics_mod,</span>        <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">virtual_specific_heat,</span> <span style="color: #f8f8f2">virtual_temperature</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">prim_si_mod,</span>        <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">preq_vertadv_v1</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">reduction_mod,</span>      <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">parallelmax,</span> <span style="color: #f8f8f2">reductionbuffer_ordered_1d_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">time_mod,</span>           <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">timelevel_qdp,</span> <span style="color: #f8f8f2">timelevel_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">prim_state_mod,</span>     <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">prim_diag_scalars,</span> <span style="color: #f8f8f2">prim_energy_halftimes</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">CAM</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">test_mod,</span>           <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">set_prescribed_wind</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  use </span><span style="color: #f8f8f2">viscosity_theta,</span>    <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">biharmonic_wk_theta</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">TRILINOS</span>
    <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">prim_derived_type_mod</span> <span style="color: #f8f8f2">,only</span> <span style="color: #f8f8f2">:</span> <span style="color: #f8f8f2">derived_type,</span> <span style="color: #f8f8f2">initialize</span>
    <span style="color: #66d9ef">use</span><span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intrinsic</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">iso_c_binding</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef"> </span>
<span style="color: #66d9ef">  implicit none</span>
<span style="color: #66d9ef">  private</span>
<span style="color: #66d9ef">  save</span>
<span style="color: #66d9ef">  public</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">prim_advance_exp,</span> <span style="color: #f8f8f2">prim_advance_init1,</span> <span style="color: #f8f8f2">advance_hypervis,</span> <span style="color: #f8f8f2">&amp;</span>
            <span style="color: #f8f8f2">applycamforcing_dynamics,</span> <span style="color: #f8f8f2">compute_andor_apply_rhs,</span> <span style="color: #f8f8f2">limiter_dp3d_k</span>

<span style="color: #66d9ef">contains</span>





<span style="color: #66d9ef">  subroutine </span><span style="color: #f8f8f2">prim_advance_init1(par,</span> <span style="color: #f8f8f2">elem,integration)</span>
        
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(parallel_t)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">par</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(element_t),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout),</span> <span style="color: #66d9ef">target</span>   <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">elem(:)</span>
    <span style="color: #66d9ef">character</span><span style="color: #f8f8f2">(len</span><span style="color: #f92672">=*</span><span style="color: #f8f8f2">)</span>    <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">integration</span>
    <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">i</span>
    <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">ie</span>


  <span style="color: #66d9ef">end subroutine </span><span style="color: #f8f8f2">prim_advance_init1</span>



  <span style="color: #75715e">!_____________________________________________________________________</span>
  <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">prim_advance_exp(elem,</span> <span style="color: #f8f8f2">deriv,</span> <span style="color: #f8f8f2">hvcoord,</span> <span style="color: #f8f8f2">hybrid,dt,</span> <span style="color: #f8f8f2">tl,</span>  <span style="color: #f8f8f2">nets,</span> <span style="color: #f8f8f2">nete,</span> <span style="color: #f8f8f2">compute_diagnostics)</span>
    <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">imex_mod,</span> <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">compute_stage_value_dirk</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">ARKODE</span>
    <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">arkode_mod,</span>     <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">parameter_list,</span> <span style="color: #f8f8f2">evolve_solution,</span> <span style="color: #f8f8f2">&amp;</span>
                              <span style="color: #f8f8f2">calc_nonlinear_stats,</span> <span style="color: #f8f8f2">update_nonlinear_stats,</span> <span style="color: #f8f8f2">&amp;</span>
                              <span style="color: #f8f8f2">rel_tol,</span> <span style="color: #f8f8f2">abs_tol</span>
    <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">arkode_tables,</span>  <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">table_list,</span> <span style="color: #f8f8f2">butcher_table_set,</span> <span style="color: #f8f8f2">set_Butcher_tables</span>
    <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">iso_c_binding</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">    type</span> <span style="color: #f8f8f2">(element_t),</span>      <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout),</span> <span style="color: #66d9ef">target</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">elem(:)</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(derivative_t),</span>   <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>            <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">deriv</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hvcoord_t)</span>                             <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hybrid_t),</span>       <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>            <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hybrid</span>
    <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>            <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dt</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(TimeLevel_t)</span>   <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>            <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">tl</span>
    <span style="color: #66d9ef">integer</span>              <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>            <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">nets</span>
    <span style="color: #66d9ef">integer</span>              <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>            <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">nete</span>
    <span style="color: #66d9ef">logical</span><span style="color: #f8f8f2">,</span>               <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>            <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">compute_diagnostics</span>

    <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dt2,</span> <span style="color: #f8f8f2">time,</span> <span style="color: #f8f8f2">dt_vis,</span> <span style="color: #f8f8f2">x,</span> <span style="color: #f8f8f2">eta_ave_w</span>
    <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">itertol,a1,a2,a3,a4,a5,a6,ahat1,ahat2</span>
    <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">ahat3,ahat4,ahat5,ahat6,dhat1,dhat2,dhat3,dhat4</span>
    <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span>  <span style="color: #f8f8f2">gamma,delta,ap,aphat,dhat5,offcenter</span>

    <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">ie,nm1,n0,np1,nstep,qsplit_stage,k,</span> <span style="color: #f8f8f2">qn0</span>
    <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">n,i,j,maxiter</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">ARKODE</span> 
    <span style="color: #66d9ef">type</span><span style="color: #f8f8f2">(parameter_list)</span>    <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">arkode_parameters</span>
    <span style="color: #66d9ef">type</span><span style="color: #f8f8f2">(table_list)</span>        <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">arkode_table_list</span>
    <span style="color: #66d9ef">type</span><span style="color: #f8f8f2">(butcher_table_set)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">arkode_table_set</span>
    <span style="color: #66d9ef">integer</span><span style="color: #f8f8f2">(</span><span style="color: #66d9ef">C_INT</span><span style="color: #f8f8f2">)</span>          <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">ierr</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">    call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&#39;prim_advance_exp&#39;</span><span style="color: #f8f8f2">)</span>
    <span style="color: #f8f8f2">nm1</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">tl%nm1</span>
    <span style="color: #f8f8f2">n0</span>    <span style="color: #f92672">=</span> <span style="color: #f8f8f2">tl%n0</span>
    <span style="color: #f8f8f2">np1</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">tl%np1</span>
    <span style="color: #f8f8f2">nstep</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">tl%nstep</span>

    <span style="color: #75715e">! get timelevel for accessing tracer mass Qdp() to compute virtual temperature</span>
    <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">TimeLevel_Qdp(tl,</span> <span style="color: #f8f8f2">qsplit,</span> <span style="color: #f8f8f2">qn0)</span>  <span style="color: #75715e">! compute current Qdp() timelevel</span>

<span style="color: #75715e">! integration = &quot;explicit&quot;</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">!   tstep_type=1  RK2</span>
<span style="color: #75715e">!   tstep_type=4  Kinnmark&amp;Gray RK 5 stage 2nd order            CFL=4.00</span>
<span style="color: #75715e">!   tstep_type=5  Kinnmark&amp;Gray RK 5 stage 3rd order            CFL=3.87  (sqrt(15))</span>
<span style="color: #75715e">!                 From Paul Ullrich.  3rd order for nonlinear terms also</span>
<span style="color: #75715e">!                 K&amp;G method is only 3rd order for linear</span>
<span style="color: #75715e">!   tstep_type=7  KG5+BE      KG5(2nd order, 4.0CFL) + BE.  1st order max stability IMEX</span>
<span style="color: #75715e">!   tstep_type=8  KG3+BE/CN   KG3 2nd order explicit, 1st order off-centering implicit</span>
<span style="color: #75715e">!   tstep_type=9  KGU53+BE/CN KGU53 3rd order explicit, 2st order implicit</span>
<span style="color: #75715e">!   tstep_type=10 KGU42+BE/optimized, from O. Guba</span>
<span style="color: #75715e">!</span>

<span style="color: #75715e">! default weights for computing mean dynamics fluxes</span>
    <span style="color: #f8f8f2">eta_ave_w</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">qsplit</span>

<span style="color: #75715e">!   this should not be needed, but in case physics update u without updating w b.c.:</span>
    <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
       <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,nlevp,n0)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
            <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">g</span>
    <span style="color: #f8f8f2">enddo</span>
 
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">CAM</span>
    <span style="color: #75715e">! if &quot;prescribed wind&quot; set dynamics explicitly and skip time-integration</span>
    <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(prescribed_wind</span> <span style="color: #f92672">==</span><span style="color: #ae81ff">1</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">       call </span><span style="color: #f8f8f2">set_prescribed_wind(elem,deriv,hybrid,hvcoord,dt,tl,nets,nete,eta_ave_w)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&#39;prim_advance_exp&#39;</span><span style="color: #f8f8f2">)</span>
       <span style="color: #66d9ef">return</span>
<span style="color: #66d9ef">    endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

    <span style="color: #75715e">! ==================================</span>
    <span style="color: #75715e">! Take timestep</span>
    <span style="color: #75715e">! ==================================</span>
    <span style="color: #f8f8f2">dt_vis</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">dt</span>
    <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> 
       <span style="color: #75715e">! RK2                                                                                                              </span>
       <span style="color: #75715e">! forward euler to u(dt/2) = u(0) + (dt/2) RHS(0)  (store in u(np1))                                               </span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,n0,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>                                              
            <span style="color: #f8f8f2">deriv,nets,nete,compute_diagnostics,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>                                                      
       <span style="color: #75715e">! leapfrog:  u(dt) = u(0) + dt RHS(dt/2)     (store in u(np1))                                                     </span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt,elem,hvcoord,hybrid,&amp;</span>                                               
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,eta_ave_w,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>                                                             


    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! explicit table from IMEX-KG254  method                                                              </span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,n0,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,compute_diagnostics,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">6</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,</span><span style="color: #ae81ff">3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">8</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>



    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
       <span style="color: #75715e">! Ullrich 3nd order 5 stage:   CFL=sqrt( 4^2 -1) = 3.87</span>
       <span style="color: #75715e">! u1 = u0 + dt/5 RHS(u0)  (save u1 in timelevel nm1)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(nm1,n0,n0,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,compute_diagnostics,eta_ave_w</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #75715e">! u2 = u0 + dt/5 RHS(u1)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,nm1,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #75715e">! u3 = u0 + dt/3 RHS(u2)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #75715e">! u4 = u0 + 2dt/3 RHS(u3)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #75715e">! compute (5*u1/4 - u0/4) in timelevel nm1:</span>
       <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
          <span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,nm1)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #ae81ff">5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
               <span style="color: #f92672">-</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,n0)</span> <span style="color: #f8f8f2">)</span> <span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nm1)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #ae81ff">5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
               <span style="color: #f92672">-</span> <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,n0)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nm1)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #ae81ff">5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f92672">-</span> <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,n0)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlevp,nm1)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #ae81ff">5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlevp,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f92672">-</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlevp,n0)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,nm1)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #ae81ff">5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f92672">-</span> <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,n0)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
       <span style="color: #f8f8f2">enddo</span>
       <span style="color: #75715e">! u5 = (5*u1/4 - u0/4) + 3dt/4 RHS(u4)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,nm1,np1,qn0,</span><span style="color: #ae81ff">3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">eta_ave_w</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #75715e">! final method is the same as:</span>
       <span style="color: #75715e">! u5 = u0 +  dt/4 RHS(u0)) + 3dt/4 RHS(u4)</span>
<span style="color: #75715e">!=========================================================================================</span>
    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">7</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! KG5(2nd order CFL=4) + BE  MAX STABILITY</span>
      <span style="color: #f8f8f2">a1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0</span>
      <span style="color: #f8f8f2">a2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">a1</span>
      <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,n0,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,compute_diagnostics,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,a1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2,np1,a2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

      <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">6</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(nm1,n0,np1,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,a1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2,nm1,a2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

      <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">8</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,nm1,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,a1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2,np1,a2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>


      <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,a1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2,np1,a2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,a1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt,np1,a2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>
      <span style="color: #75715e">!  u0 saved in elem(n0)</span>
      <span style="color: #75715e">!  u2 saved in elem(nm1)</span>
      <span style="color: #75715e">!  u4 saved in elem(np1)</span>
      <span style="color: #75715e">!  u5 = u0 + dt*N(u4) + dt*6/22*S(u0) + dt*6/22 S(u1) + dt*10/22* S(u5)</span>
<span style="color: #75715e">!===================================================================================</span>
   <span style="color: #f8f8f2">elseif</span> <span style="color: #f8f8f2">(tstep_type</span> <span style="color: #f92672">==</span> <span style="color: #ae81ff">8</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! KG3 + CN + offcentering</span>

      <span style="color: #75715e">! introduce 1st order offcentering</span>
      <span style="color: #f8f8f2">offcenter</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.5</span><span style="color: #f8f8f2">d0</span>
      <span style="color: #f8f8f2">aphat</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.5</span><span style="color: #f8f8f2">d0</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">offcenter</span>
      <span style="color: #f8f8f2">dhat3</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.5</span><span style="color: #f8f8f2">d0</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">offcenter</span>

      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,n0,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,compute_diagnostics,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0)</span> <span style="color: #75715e">!   aphat/ap,1d0)               </span>

      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,aphat</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,np1,dhat3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0)</span>

      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,aphat</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,np1,dhat3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

      <span style="color: #75715e">! introduce 1st order offcentering</span>
      <span style="color: #f8f8f2">offcenter</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.01</span><span style="color: #f8f8f2">d0</span>
      <span style="color: #f8f8f2">aphat</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.5</span><span style="color: #f8f8f2">d0</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">offcenter</span>
      <span style="color: #f8f8f2">dhat3</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.5</span><span style="color: #f8f8f2">d0</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">offcenter</span>

      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt,elem,hvcoord,hybrid,&amp;</span>
           <span style="color: #f8f8f2">deriv,nets,nete,.false.,eta_ave_w,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,aphat</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt,np1,dhat3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">9</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> 
       <span style="color: #75715e">! KGU5-3 (3rd order) with IMEX backward euler (2nd order)</span>
       <span style="color: #75715e">! </span>
       <span style="color: #75715e">! u1 = u0 + dt/5 RHS(u0)  (save u1 in timelevel nm1)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(nm1,n0,n0,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,compute_diagnostics,eta_ave_w</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,nm1,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">,qn0,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

       <span style="color: #75715e">! u2 = u0 + dt/5 RHS(u1)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,nm1,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,np1,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">,qn0,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

       <span style="color: #75715e">! u3 = u0 + dt/3 RHS(u2)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,np1,dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,qn0,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

       <span style="color: #75715e">! u4 = u0 + 2dt/3 RHS(u3)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,np1,</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,qn0,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>


       <span style="color: #75715e">! u5 = u1 + dt 3/4 RHS(u4)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,nm1,np1,qn0,</span><span style="color: #ae81ff">3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">eta_ave_w</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
       <span style="color: #75715e">! u(np1) = [u1 + 3dt/4 RHS(u4)] +  1/4 (u1 - u0)    STABLE</span>
       <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
          <span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,np1)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,np1)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
               <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,:,:,nm1)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,n0))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,np1)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,np1)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
               <span style="color: #f8f8f2">(elem(ie)%state%vtheta_dp(:,:,:,nm1)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,n0))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,np1)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,np1)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
               <span style="color: #f8f8f2">(elem(ie)%state%dp3d(:,:,:,nm1)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,n0))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlevp,np1)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlevp,np1)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
              <span style="color: #f8f8f2">(elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlevp,nm1)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlevp,n0))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,np1)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,np1)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
               <span style="color: #f8f8f2">(elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,nm1)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,n0))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
          <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">limiter_dp3d_k(elem(ie)%state%dp3d(:,:,:,np1),elem(ie)%state%vtheta_dp(:,:,:,np1),&amp;</span>
               <span style="color: #f8f8f2">elem(ie)%spheremp,hvcoord%dp0)</span>
       <span style="color: #f8f8f2">enddo</span>

       <span style="color: #75715e">!  n0          nm1       np1 </span>
       <span style="color: #75715e">! u0*5/18  + u1*5/18  + u5*8/18</span>
       <span style="color: #f8f8f2">a1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">18</span>
       <span style="color: #f8f8f2">a2</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">36</span>    <span style="color: #75715e">! 5/18 - 1/4 (due to the 1/4*u1 added above)</span>
       <span style="color: #f8f8f2">a3</span><span style="color: #f92672">=</span><span style="color: #ae81ff">8</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">18</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,a2,n0,a1,np1,a3,qn0,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">10</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! KG5(2nd order CFL=4) + optimized</span>
      <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(nm1,n0,n0,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,compute_diagnostics,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,nm1,dt2,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

      <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">6</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,nm1,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,np1,dt2,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

      <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">8</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,np1,dt2,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>


      <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,n0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,np1,dt2,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>

      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,n0,np1,qn0,dt,elem,hvcoord,hybrid,&amp;</span>
            <span style="color: #f8f8f2">deriv,nets,nete,.false.,eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">d0,</span><span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0)</span>


      <span style="color: #f8f8f2">a1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">.24362</span><span style="color: #f8f8f2">d0</span>   
      <span style="color: #f8f8f2">a2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">.34184</span><span style="color: #f8f8f2">d0</span> 
      <span style="color: #f8f8f2">a3</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">(a1</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">a2)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">compute_stage_value_dirk(nm1,a2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt,n0,a1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt,np1,a3</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt,qn0,elem,hvcoord,hybrid,&amp;</span>
        <span style="color: #f8f8f2">deriv,nets,nete,maxiter,itertol)</span>
      <span style="color: #75715e">!  u0 saved in elem(n0)</span>
      <span style="color: #75715e">!  u1 saved in elem(nm1)</span>
      <span style="color: #75715e">!  u4 saved in elem(np1)</span>



<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">ARKODE</span>
    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">20</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode RK2</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%RK2)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">21</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Kinnmark, Gray, Ullrich 3rd-order, 5-stage</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%KGU35)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">22</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Ascher 2nd/2nd/2nd-order, 3-stage</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%ARS232)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">23</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Candidate ARK453 Method</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%ARK453)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">24</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Ascher 2nd/2nd/2nd-order, 3-stage</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%ARS222)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">25</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Ascher 3rd/4th/3rd-order, 3-stage</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%ARS233)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">26</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Ascher 3rd/3rd/3rd-order, 4-stage</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%ARS343)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">27</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Ascher 3rd/3rd/3rd-order, 5-stage</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%ARS443)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">28</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Kennedy 3rd/3rd/3rd-order, 4-stage</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%ARK324)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">29</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Kennedy 4th/4th/4th-order, 6-stage</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%ARK436)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">30</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Conde et al ssp3(3,3,3)a (renamed here)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%SSP3333B)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">31</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode Conde et al ssp3(3,3,3)b (renamed here)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%SSP3333C)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">32</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 2nd-order, 4 stage (2 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG232)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">33</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 2nd-order, 5 stage (2 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG242)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">34</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 2nd-order, 5 stage (3 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG243)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">35</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 2nd-order, 6 stage (2 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG252)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">36</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 2nd-order, 6 stage (3 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG253)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">37</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 2nd-order, 6 stage (4 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG254)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">38</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 3rd-order, 5 stage (2 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG342)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">39</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 3rd-order, 5 stage (3 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG343)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">40</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 3rd-order, 6 stage (3 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG353)</span>

    <span style="color: #66d9ef">else if</span> <span style="color: #f8f8f2">(tstep_type</span><span style="color: #f92672">==</span><span style="color: #ae81ff">41</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> <span style="color: #75715e">! ARKode IMKG 3rd-order, 6 stage (4 implicit)</span>
      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">set_Butcher_tables(arkode_table_set,</span> <span style="color: #f8f8f2">arkode_table_list%IMKG354)</span>

    <span style="color: #66d9ef">else </span>
<span style="color: #66d9ef">       call </span><span style="color: #f8f8f2">abortmp(</span><span style="color: #e6db74">&#39;ERROR: bad choice of tstep_type&#39;</span><span style="color: #f8f8f2">)</span>
    <span style="color: #66d9ef">endif</span>

    <span style="color: #75715e">! Use ARKode to advance solution</span>
    <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(tstep_type</span> <span style="color: #f92672">&gt;=</span> <span style="color: #ae81ff">20</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>

      <span style="color: #75715e">! If implicit solves are involved, set corresponding parameters</span>
      <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(arkode_table_set%imex</span> <span style="color: #f92672">/=</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
        <span style="color: #75715e">! Iteration tolerances (appear in WRMS array as rtol*|u_i| + atol_i)</span>
        <span style="color: #f8f8f2">arkode_parameters%rtol</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">rel_tol</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(abs_tol</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0.</span><span style="color: #f8f8f2">d0)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">          </span><span style="color: #f8f8f2">arkode_parameters%atol(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">arkode_parameters%rtol</span> <span style="color: #75715e">! assumes u ~ 1e1</span>
          <span style="color: #f8f8f2">arkode_parameters%atol(</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">arkode_parameters%rtol</span> <span style="color: #75715e">! assumes v ~ 1e1</span>
          <span style="color: #f8f8f2">arkode_parameters%atol(</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">arkode_parameters%rtol</span> <span style="color: #75715e">! assumes w_i ~ 1e1</span>
          <span style="color: #f8f8f2">arkode_parameters%atol(</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">arkode_parameters%rtol</span> <span style="color: #75715e">! assumes phinh_i ~ 1e5</span>
          <span style="color: #f8f8f2">arkode_parameters%atol(</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">arkode_parameters%rtol</span> <span style="color: #75715e">! assumes vtheta_dp ~ 1e6</span>
          <span style="color: #f8f8f2">arkode_parameters%atol(</span><span style="color: #ae81ff">6</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1.</span><span style="color: #f8f8f2">d0</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">arkode_parameters%rtol</span> <span style="color: #75715e">! assumes dp3d ~ 1e0</span>
        <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">          </span><span style="color: #f8f8f2">arkode_parameters%atol(:)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">abs_tol</span>
        <span style="color: #66d9ef">end if</span>
<span style="color: #66d9ef">      end if</span>

      <span style="color: #75715e">! use ARKode solver to evolve solution</span>
      <span style="color: #f8f8f2">ierr</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">evolve_solution(elem,</span> <span style="color: #f8f8f2">nets,</span> <span style="color: #f8f8f2">nete,</span> <span style="color: #f8f8f2">deriv,</span> <span style="color: #f8f8f2">hvcoord,</span> <span style="color: #f8f8f2">hybrid,</span> <span style="color: #f8f8f2">&amp;</span>
                             <span style="color: #f8f8f2">dt,</span> <span style="color: #f8f8f2">eta_ave_w,</span> <span style="color: #f8f8f2">n0,</span> <span style="color: #f8f8f2">np1,</span> <span style="color: #f8f8f2">qn0,</span> <span style="color: #f8f8f2">arkode_parameters,</span> <span style="color: #f8f8f2">&amp;</span>
                             <span style="color: #f8f8f2">arkode_table_set)</span>
      <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(ierr</span> <span style="color: #f92672">/=</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        call </span><span style="color: #f8f8f2">abortmp(</span><span style="color: #e6db74">&#39;ARKode evolve failed&#39;</span><span style="color: #f8f8f2">)</span>
      <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">      if</span> <span style="color: #f8f8f2">(calc_nonlinear_stats)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        call </span><span style="color: #f8f8f2">update_nonlinear_stats()</span>
      <span style="color: #66d9ef">end if</span>
<span style="color: #66d9ef">    end if</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">    else </span>
<span style="color: #66d9ef">       call </span><span style="color: #f8f8f2">abortmp(</span><span style="color: #e6db74">&#39;ERROR: bad choice of tstep_type&#39;</span><span style="color: #f8f8f2">)</span>
    <span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>


    <span style="color: #75715e">! ==============================================</span>
    <span style="color: #75715e">! Time-split Horizontal diffusion: nu.del^2 or nu.del^4</span>
    <span style="color: #75715e">! U(*) = U(t+1)  + dt2 * HYPER_DIFF_TERM(t+1)</span>
    <span style="color: #75715e">! ==============================================</span>
    <span style="color: #75715e">! note:time step computes u(t+1)= u(t*) + RHS.</span>
    <span style="color: #75715e">! for consistency, dt_vis = t-1 - t*, so this is timestep method dependent</span>
    <span style="color: #75715e">! forward-in-time, hypervis applied to dp3d</span>
    <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(compute_diagnostics)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">       call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&quot;prim_diag&quot;</span><span style="color: #f8f8f2">)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">prim_energy_halftimes(elem,hvcoord,tl,</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">,.false.,nets,nete)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">prim_diag_scalars(elem,hvcoord,tl,</span><span style="color: #ae81ff">5</span><span style="color: #f8f8f2">,.false.,nets,nete)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&quot;prim_diag&quot;</span><span style="color: #f8f8f2">)</span>
    <span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">    if</span> <span style="color: #f8f8f2">(hypervis_order</span> <span style="color: #f92672">==</span> <span style="color: #ae81ff">2</span> <span style="color: #f92672">.and.</span> <span style="color: #f8f8f2">nu</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">&amp;</span>
         <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">advance_hypervis(elem,hvcoord,hybrid,deriv,np1,nets,nete,dt_vis,eta_ave_w)</span>


    <span style="color: #75715e">! warning: advance_physical_vis currently requires levels that are equally spaced in z</span>
    <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(dcmip16_mu</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">advance_physical_vis(elem,hvcoord,hybrid,deriv,np1,nets,nete,dt,dcmip16_mu_s,dcmip16_mu)</span>

    <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(compute_diagnostics)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">       call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&quot;prim_diag&quot;</span><span style="color: #f8f8f2">)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">prim_energy_halftimes(elem,hvcoord,tl,</span><span style="color: #ae81ff">6</span><span style="color: #f8f8f2">,.false.,nets,nete)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">prim_diag_scalars(elem,hvcoord,tl,</span><span style="color: #ae81ff">6</span><span style="color: #f8f8f2">,.false.,nets,nete)</span>
       <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&quot;prim_diag&quot;</span><span style="color: #f8f8f2">)</span>
    <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">    call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&#39;prim_advance_exp&#39;</span><span style="color: #f8f8f2">)</span>
  <span style="color: #66d9ef">end subroutine </span><span style="color: #f8f8f2">prim_advance_exp</span>

<span style="color: #75715e">!----------------------------- APPLYCAMFORCING-DYNAMICS ----------------------------</span>

  <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">applyCAMforcing_dynamics(elem,hvcoord,np1,dt,nets,nete)</span>

  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(element_t)</span>     <span style="color: #f8f8f2">,</span>  <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">elem(:)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span>  <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>    <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dt</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hvcoord_t),</span>       <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>    <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>
  <span style="color: #66d9ef">integer</span><span style="color: #f8f8f2">,</span>                <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>    <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">np1,nets,nete</span>

  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">k,ie</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>

     <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,np1)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%FVTheta(:,:,:)</span>
     <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,np1)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%FPHI(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev)</span>

     <span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,np1)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%FM(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,:)</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">CAM</span>
     <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:nlev,np1)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%FM(:,:,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,:)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

     <span style="color: #75715e">! finally update w at the surface: </span>
     <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,nlevp,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,np1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,np1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">g</span>
  <span style="color: #f8f8f2">enddo</span>
  
  <span style="color: #66d9ef">end subroutine </span><span style="color: #f8f8f2">applyCAMforcing_dynamics</span>


<span style="color: #75715e">!----------------------------- ADVANCE-HYPERVIS ----------------------------</span>

  <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">advance_hypervis(elem,hvcoord,hybrid,deriv,nt,nets,nete,dt2,eta_ave_w)</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">!  take one timestep of:</span>
  <span style="color: #75715e">!          u(:,:,:,np) = u(:,:,:,np) +  dt2*nu*laplacian**order ( u )</span>
  <span style="color: #75715e">!          T(:,:,:,np) = T(:,:,:,np) +  dt2*nu_s*laplacian**order ( T )</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">!  For correct scaling, dt2 should be the same &#39;dt2&#39; used in the leapfrog advace</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">!</span>

  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hybrid_t)</span>      <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hybrid</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(element_t)</span>     <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout),</span> <span style="color: #66d9ef">target</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">elem(:)</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(derivative_t)</span>  <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">deriv</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hvcoord_t),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>      <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dt2</span>
  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">nets,nete</span>

  <span style="color: #75715e">! local</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">eta_ave_w</span>  <span style="color: #75715e">! weighting for mean flux terms</span>
  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">k2,k,kptr,i,j,ie,ic,nt,nlyr_tot,nlyr_tom,ssize</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,nets:nete)</span>      <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtens</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,nlev,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,nets:nete)</span>      <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">stens</span>  <span style="color: #75715e">! dp3d,theta,w,phi</span>


<span style="color: #75715e">! NOTE: PGI compiler bug: when using spheremp, rspheremp and ps as pointers to elem(ie)% members,</span>
  <span style="color: #75715e">!       data is incorrect (offset by a few numbers actually)</span>
  <span style="color: #75715e">!       removed for now.</span>
  <span style="color: #75715e">!       real (kind=real_kind), dimension(:,:), pointer :: spheremp,rspheremp</span>
  <span style="color: #75715e">!       real (kind=real_kind), dimension(:,:,:), pointer   :: ps</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">lap_s</span>  <span style="color: #75715e">! dp3d,theta,w,phi</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">lap_v</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">exner0(nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">heating(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">exner(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pnh(np,np,nlevp)</span>    
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">temp(np,np,nlev)</span>    
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">temp_i(np,np,nlevp)</span>    
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dt,xfac</span>

  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">l1p,l2p,l1n,l2n,l</span>
  <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&#39;advance_hypervis&#39;</span><span style="color: #f8f8f2">)</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
  <span style="color: #75715e">! Exchange all vars even in hydro mode, for the sake of bfb comparison with xx code</span>
  <span style="color: #f8f8f2">nlyr_tot</span><span style="color: #f92672">=</span><span style="color: #ae81ff">6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>  <span style="color: #75715e">! total amount of data for DSS</span>
  <span style="color: #f8f8f2">nlyr_tom</span><span style="color: #f92672">=</span><span style="color: #ae81ff">6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev_tom</span>
  <span style="color: #f8f8f2">ssize</span><span style="color: #f92672">=</span><span style="color: #ae81ff">4</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">  if</span> <span style="color: #f8f8f2">(theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">nlyr_tot</span><span style="color: #f92672">=</span><span style="color: #ae81ff">4</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>        <span style="color: #75715e">! dont bother to dss w_i and phinh_i</span>
     <span style="color: #f8f8f2">nlyr_tom</span><span style="color: #f92672">=</span><span style="color: #ae81ff">4</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev_tom</span>
     <span style="color: #f8f8f2">ssize</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>
  <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">nlyr_tot</span><span style="color: #f92672">=</span><span style="color: #ae81ff">6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>  <span style="color: #75715e">! total amount of data for DSS</span>
     <span style="color: #f8f8f2">nlyr_tom</span><span style="color: #f92672">=</span><span style="color: #ae81ff">6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev_tom</span>
     <span style="color: #f8f8f2">ssize</span><span style="color: #f92672">=</span><span style="color: #ae81ff">4</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>
  <span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  </span>
<span style="color: #66d9ef">  do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
     <span style="color: #f8f8f2">exner0(k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(hvcoord%etam(k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">hvcoord%ps0</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">**</span><span style="color: #f8f8f2">kappa</span>
  <span style="color: #f8f8f2">enddo</span>


  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
     <span style="color: #75715e">! convert vtheta_dp -&gt; theta</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nt)</span>
     <span style="color: #f8f8f2">enddo</span>
  <span style="color: #f8f8f2">enddo</span>

<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</span>
  <span style="color: #75715e">!  hyper viscosity</span>
<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</span>
  <span style="color: #f8f8f2">dt</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">hypervis_subcycle</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ic</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,hypervis_subcycle</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
        <span style="color: #75715e">! remove ref state</span>
        <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%theta_ref(:,:,:)</span>
        <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,:,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,:,nt)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%phi_ref(:,:,:)</span>
        <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%dp_ref(:,:,:)</span>
     <span style="color: #f8f8f2">enddo</span>
     
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">biharmonic_wk_theta(elem,stens,vtens,deriv,edge_g,hybrid,nt,nets,nete)</span>
     
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
        <span style="color: #75715e">!add ref state back</span>
        <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%theta_ref(:,:,:)</span>
        <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,:,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,:,nt)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%phi_ref(:,:,:)</span>
        <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%dp_ref(:,:,:)</span>
        
        
        <span style="color: #75715e">! comptue mean flux</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(nu_p</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">elem(ie)%derived%dpdiss_ave(:,:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%derived%dpdiss_ave(:,:,:)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">hypervis_subcycle</span>
           <span style="color: #f8f8f2">elem(ie)%derived%dpdiss_biharmonic(:,:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%derived%dpdiss_biharmonic(:,:,:)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">hypervis_subcycle</span>
        <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
           <span style="color: #f8f8f2">vtens(:,:,:,k,ie)</span><span style="color: #f92672">=-</span><span style="color: #f8f8f2">nu</span>  <span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,:,k,ie)</span> <span style="color: #75715e">! u,v</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=-</span><span style="color: #f8f8f2">nu_p</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #75715e">! dp3d</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=-</span><span style="color: #f8f8f2">nu</span>  <span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #75715e">! theta</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=-</span><span style="color: #f8f8f2">nu</span>  <span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #75715e">! w</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=-</span><span style="color: #f8f8f2">nu_s</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #75715e">! phi</span>
        <span style="color: #f8f8f2">enddo</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(nu_top</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0</span> <span style="color: #f92672">.and.</span> <span style="color: #f8f8f2">hypervis_subcycle_tom</span><span style="color: #f92672">==</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev_tom</span>
              <span style="color: #75715e">!vtheta_dp(:,:)=elem(ie)%state%vtheta_dp(:,:,k,nt)*elem(ie)%state%dp3d(:,:,k,nt)/hvcoord%dp0(k)</span>
              <span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%dp3d</span>       <span style="color: #f8f8f2">(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
              <span style="color: #75715e">!lap_s(:,:,2)=laplace_sphere_wk(vtheta_dp                           ,deriv,elem(ie),var_coef=.false.)</span>
              <span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%vtheta_dp(:,:,k,nt)</span>  <span style="color: #f8f8f2">,deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
              <span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%w_i</span>        <span style="color: #f8f8f2">(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
              <span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%phinh_i</span>    <span style="color: #f8f8f2">(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
              <span style="color: #f8f8f2">lap_v</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vlaplace_sphere_wk(elem(ie)%state%v(:,:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>

              <span style="color: #f8f8f2">vtens(:,:,:,k,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtens(:,:,:,k,ie)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">nu_scale_top(k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nu_top</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_v(:,:,:)</span> <span style="color: #75715e">! u and v</span>
              <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">nu_scale_top(k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nu_top</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #75715e">! dp3d</span>
              <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">nu_scale_top(k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nu_top</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span> <span style="color: #75715e">! theta</span>
              <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">nu_scale_top(k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nu_top</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">)</span> <span style="color: #75715e">! w</span>
              <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">nu_scale_top(k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nu_top</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">)</span> <span style="color: #75715e">! phi</span>
           <span style="color: #f8f8f2">enddo</span>
        <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span>      <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,vtens(:,:,:,:,ie),</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev,kptr,nlyr_tot)</span>
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev;</span> <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,:,ie),ssize,kptr,nlyr_tot)</span>
        
     <span style="color: #f8f8f2">enddo</span>

     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&#39;ahdp_bexchV2&#39;</span><span style="color: #f8f8f2">)</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">bndry_exchangeV(hybrid,edge_g)</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&#39;ahdp_bexchV2&#39;</span><span style="color: #f8f8f2">)</span>
     
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
        
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,vtens(:,:,:,:,ie),</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev,kptr,nlyr_tot)</span>
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,:,ie),ssize,kptr,nlyr_tot)</span>
        
        
        <span style="color: #75715e">! apply inverse mass matrix, accumulate tendencies</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
           <span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt)</span>  <span style="color: #75715e">! u</span>
           <span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt)</span>  <span style="color: #75715e">! v</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt)</span>  <span style="color: #75715e">! dp3d</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt)</span>  <span style="color: #75715e">! theta</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt)</span>  <span style="color: #75715e">! w</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt)</span>  <span style="color: #75715e">! phi</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>  <span style="color: #75715e">! u</span>
           <span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>  <span style="color: #75715e">! v</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>  <span style="color: #75715e">! dp3d</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>  <span style="color: #75715e">! theta</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>  <span style="color: #75715e">! w</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>  <span style="color: #75715e">! phi</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">enddo</span>
        
        
        <span style="color: #75715e">! apply heating after updating state.  using updated v gives better results in PREQX model</span>
        <span style="color: #75715e">!</span>
        <span style="color: #75715e">! d(IE)/dt =  cp*exner*d(Theta)/dt + phi d(dp3d)/dt   (Theta = dp3d*theta)</span>
        <span style="color: #75715e">!   Our eqation:  d(theta)/dt = diss(theta) - heating</span>
        <span style="color: #75715e">!   Assuming no diffusion on dp3d, we can approximate by:</span>
        <span style="color: #75715e">!   d(IE)/dt = exner*cp*dp3d * diss(theta)  - exner*cp*dp3d*heating               </span>
        <span style="color: #75715e">!</span>
        <span style="color: #75715e">! KE dissipaiton will be given by:</span>
        <span style="color: #75715e">!   d(KE)/dt = dp3d*U dot diss(U)</span>
        <span style="color: #75715e">! we want exner*cp*dp3d*heating = dp3d*U dot diss(U)</span>
        <span style="color: #75715e">! and thus heating =  U dot diss(U) / exner*cp</span>
        <span style="color: #75715e">! </span>
        <span style="color: #75715e">! compute exner needed for heating term and IE scaling</span>
        <span style="color: #75715e">! this is using a mixture of data before viscosity and after viscosity </span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">if </span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">temp(:,:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">pnh_and_exner_from_eos(hvcoord,temp,&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt),elem(ie)%state%phinh_i(:,:,:,nt),&amp;</span>
             <span style="color: #f8f8f2">pnh,exner,temp_i,caller</span><span style="color: #f92672">=</span><span style="color: #e6db74">&#39;advance_hypervis&#39;</span><span style="color: #f8f8f2">)</span>
        
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
           <span style="color: #f8f8f2">k2</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">min(k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev)</span>
           <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">              </span><span style="color: #f8f8f2">heating(:,:,k)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span> <span style="color: #f8f8f2">)</span> <span style="color: #f92672">/</span> <span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f8f8f2">(exner(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">Cp)</span>

           <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">              </span><span style="color: #f8f8f2">heating(:,:,k)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span>  <span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f8f8f2">(elem(ie)%state%w_i(:,:,k,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span>  <span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
                     <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k2,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k2,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span> <span style="color: #f8f8f2">)</span> <span style="color: #f92672">/</span>  <span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f8f8f2">(exner(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">Cp)</span>  
           <span style="color: #66d9ef">endif</span>
           <span style="color: #75715e">!elem(ie)%state%vtheta_dp(:,:,k,nt)=elem(ie)%state%vtheta_dp(:,:,k,nt) &amp;</span>
           <span style="color: #75715e">!     +stens(:,:,k,2,ie)*hvcoord%dp0(k)*exner0(k)/(exner(:,:,k)*elem(ie)%state%dp3d(:,:,k,nt)&amp;</span>
           <span style="color: #75715e">!     )  -heating(:,:,k)</span>
           <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f92672">-</span><span style="color: #f8f8f2">heating(:,:,k)</span>
        <span style="color: #f8f8f2">enddo</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">        do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
           <span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,k,nt)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">vtens(:,:,:,k,ie)</span>
           <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span>
           
           <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span>
           
           <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span>

           <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span>
        <span style="color: #f8f8f2">enddo</span>




     <span style="color: #f8f8f2">enddo</span> <span style="color: #75715e">! ie</span>
  <span style="color: #f8f8f2">enddo</span>  <span style="color: #75715e">! subcycle</span>

<span style="color: #75715e">! convert vtheta_dp -&gt; theta</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>            
     <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span>
    
     <span style="color: #75715e">! finally update w at the surface: </span>
     <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,nlevp,nt)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">g</span>
  <span style="color: #f8f8f2">enddo</span>





<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</span>
  <span style="color: #75715e">!  sponge layer</span>
<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</span>
  <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(nu_top</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0</span> <span style="color: #f92672">.and.</span> <span style="color: #f8f8f2">hypervis_subcycle_tom</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">  </span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">hypervis_subcycle_tom</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ic</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,hypervis_subcycle_tom</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev_tom</span>
           <span style="color: #75715e">! add regular diffusion near top</span>
           <span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%dp3d</span>     <span style="color: #f8f8f2">(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
           <span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%vtheta_dp(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
           <span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%w_i</span>      <span style="color: #f8f8f2">(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
           <span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%phinh_i</span>  <span style="color: #f8f8f2">(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
           <span style="color: #f8f8f2">lap_v</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vlaplace_sphere_wk(elem(ie)%state%v</span>            <span style="color: #f8f8f2">(:,:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>
           
           <span style="color: #f8f8f2">xfac</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nu_scale_top(k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nu_top</span>

           <span style="color: #f8f8f2">vtens(:,:,:,k,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">xfac</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_v(:,:,:)</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">xfac</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>  <span style="color: #75715e">! dp3d</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">xfac</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span>  <span style="color: #75715e">! vtheta_dp</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">xfac</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">)</span>  <span style="color: #75715e">! w_i</span>
           <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">xfac</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">lap_s(:,:,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">)</span>  <span style="color: #75715e">! phi_i</span>
        <span style="color: #f8f8f2">enddo</span>
        
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span>      
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,vtens(:,:,:,:,ie),</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev_tom,kptr,nlyr_tom)</span>
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev_tom;</span> 
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie),nlev_tom,kptr,nlyr_tom)</span>
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev_tom</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie),nlev_tom,kptr,nlyr_tom)</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">.not.</span><span style="color: #f8f8f2">theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev_tom</span>
           <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie),nlev_tom,kptr,nlyr_tom)</span>
           <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev_tom</span>
           <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie),nlev_tom,kptr,nlyr_tom)</span>
        <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">enddo</span>
     
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&#39;ahdp_bexchV2&#39;</span><span style="color: #f8f8f2">)</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">bndry_exchangeV(hybrid,edge_g)</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&#39;ahdp_bexchV2&#39;</span><span style="color: #f8f8f2">)</span>
     
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
        
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,vtens(:,:,:,:,ie),</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev_tom,kptr,nlyr_tom)</span>
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev_tom</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie),nlev_tom,kptr,nlyr_tom)</span>
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev_tom</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie),nlev_tom,kptr,nlyr_tom)</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">.not.</span><span style="color: #f8f8f2">theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev_tom</span>
           <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie),nlev_tom,kptr,nlyr_tom)</span>
           <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev_tom</span>
           <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie),nlev_tom,kptr,nlyr_tom)</span>
        <span style="color: #66d9ef">endif</span>
        
        
        <span style="color: #75715e">! apply inverse mass matrix, add tendency</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev_tom</span>
           <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,nt)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
           <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,nt)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
           <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
           
           <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
           <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>

           <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
        <span style="color: #f8f8f2">enddo</span>
     <span style="color: #f8f8f2">enddo</span> <span style="color: #75715e">! ie</span>
  <span style="color: #f8f8f2">enddo</span>  <span style="color: #75715e">! subcycle</span>
  <span style="color: #66d9ef">endif</span>



<span style="color: #66d9ef">  call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&#39;advance_hypervis&#39;</span><span style="color: #f8f8f2">)</span>

  <span style="color: #66d9ef">end subroutine </span><span style="color: #f8f8f2">advance_hypervis</span>





  <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">advance_physical_vis(elem,hvcoord,hybrid,deriv,nt,nets,nete,dt,mu_s,mu)</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">!  take one timestep of of physical viscosity (single laplace operator) for</span>
  <span style="color: #75715e">!  all state variables in both horizontal and vertical</span>
  <span style="color: #75715e">!  </span>
  <span style="color: #75715e">!  as of 2017/5, used only for the supercell test case</span>
  <span style="color: #75715e">!  so for now:</span>
  <span style="color: #75715e">!     dont bother to optimize</span>
  <span style="color: #75715e">!     apply only to perturbation from background state (supercell initial condition)</span>
  <span style="color: #75715e">!     uniform spacing in z with delz = 20km/nlev</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">!</span>

  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hybrid_t)</span>      <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hybrid</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(element_t)</span>     <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout),</span> <span style="color: #66d9ef">target</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">elem(:)</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(derivative_t)</span>  <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">deriv</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hvcoord_t),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>      <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dt,</span> <span style="color: #f8f8f2">mu_s,</span> <span style="color: #f8f8f2">mu</span>
  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">nt,nets,nete</span>

  <span style="color: #75715e">! local</span>
  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">k,kptr,ie</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,nets:nete)</span>      <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtens</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,nlev,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,nets:nete)</span>      <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">stens</span>  <span style="color: #75715e">! dp3d,theta,w,phi</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,nlevp,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nets:nete)</span>     <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">stens_i</span> 


  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">lap_v</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">delz,delz_i</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">theta_ref(np,np,nlev)</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">theta_prime(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">phi_prime(np,np,nlevp)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp_prime(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">w_prime(np,np,nlevp)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">u_prime(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev)</span>

  <span style="color: #75715e">!if(test_case .ne. &#39;dcmip2016_test3&#39;) call abortmp(&quot;dcmip16_mu is currently limited to dcmip16 test 3&quot;)</span>

  <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&#39;advance_physical_vis&#39;</span><span style="color: #f8f8f2">)</span>
  <span style="color: #f8f8f2">delz</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">20</span><span style="color: #f8f8f2">d3</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">nlev</span>
  <span style="color: #f8f8f2">delz_i</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">20</span><span style="color: #f8f8f2">d3</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">nlevp</span>

<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</span>
<span style="color: #75715e">! compute reference states</span>
<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>

     <span style="color: #f8f8f2">theta_ref(:,:,:)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">state0(ie)%vtheta_dp(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">state0(ie)%dp3d(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
     <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span>

     <span style="color: #75715e">! perturbation variables</span>
     <span style="color: #f8f8f2">u_prime(:,:,:,:)</span>  <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,:,:,nt)</span>          <span style="color: #f92672">-</span><span style="color: #f8f8f2">state0(ie)%v(:,:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
     <span style="color: #f8f8f2">w_prime(:,:,:)</span>    <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,:,nt)</span>     <span style="color: #f92672">-</span><span style="color: #f8f8f2">state0(ie)%w_i(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
     <span style="color: #f8f8f2">dp_prime(:,:,:)</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,nt)</span>         <span style="color: #f92672">-</span><span style="color: #f8f8f2">state0(ie)%dp3d(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
     <span style="color: #f8f8f2">phi_prime(:,:,:)</span>  <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,:,nt)</span> <span style="color: #f92672">-</span><span style="color: #f8f8f2">state0(ie)%phinh_i(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
     <span style="color: #f8f8f2">theta_prime(:,:,:)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,nt)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">theta_ref(:,:,:)</span>

     <span style="color: #75715e">! vertical viscosity</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">laplace_z(u_prime,</span>    <span style="color: #f8f8f2">vtens(:,:,:,:,ie),</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,delz)</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">laplace_z(dp_prime,</span>   <span style="color: #f8f8f2">stens(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie),</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,delz)</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">laplace_z(theta_prime,stens(:,:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie),</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,delz)</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">laplace_z(w_prime,</span>    <span style="color: #f8f8f2">stens_i(:,:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie),</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlevp,delz_i)</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">laplace_z(phi_prime,</span>  <span style="color: #f8f8f2">stens_i(:,:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie),</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlevp,delz_i)</span>

     <span style="color: #75715e">! add in horizontal viscosity</span>
     <span style="color: #75715e">! multiply by mass matrix for DSS</span>
     <span style="color: #75715e">! horiz viscosity already has mass matrix built in</span>
     <span style="color: #75715e">! for interface quantities, only use 1:nlev (dont apply at surface)</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">lap_v</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">vlaplace_sphere_wk(elem(ie)%state%v(:,:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>

        <span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">lap_v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span>
        <span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">lap_v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">))</span>

        <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%dp3d(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>  <span style="color: #f8f8f2">)</span>

        <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%vtheta_dp(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span>  <span style="color: #f8f8f2">)</span>

        <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(stens_i(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%w_i(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span> <span style="color: #f8f8f2">)</span>

        <span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(stens_i(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">laplace_sphere_wk(elem(ie)%state%phinh_i(:,:,k,nt),deriv,elem(ie),var_coef</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.)</span> <span style="color: #f8f8f2">)</span> 

     <span style="color: #f8f8f2">enddo</span>

     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,vtens(:,:,:,:,ie),</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev,kptr,</span><span style="color: #ae81ff">6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev)</span>
     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,:,ie),</span><span style="color: #ae81ff">4</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev,kptr,</span><span style="color: #ae81ff">6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev)</span>
     
  <span style="color: #f8f8f2">enddo</span>

  <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">bndry_exchangeV(hybrid,edge_g)</span>
  
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
     
     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,vtens(:,:,:,:,ie),</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev,kptr,</span><span style="color: #ae81ff">6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev)</span>
     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,stens(:,:,:,:,ie),</span><span style="color: #ae81ff">4</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev,kptr,</span><span style="color: #ae81ff">6</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev)</span>
     
     <span style="color: #75715e">! apply inverse mass matrix, accumulate tendencies</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,nt)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">mu</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>

        <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,nt)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">mu</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
        
        <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f92672">+</span><span style="color: #f8f8f2">mu_s</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
        
        <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f92672">+</span><span style="color: #f8f8f2">mu_s</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>

        <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f92672">+</span><span style="color: #f8f8f2">mu_s</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
        
        <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,nt)</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f92672">+</span><span style="color: #f8f8f2">mu_s</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">stens(:,:,k,</span><span style="color: #ae81ff">4</span><span style="color: #f8f8f2">,ie)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span>
        
     <span style="color: #f8f8f2">enddo</span>
  <span style="color: #f8f8f2">enddo</span>


  <span style="color: #75715e">! convert vtheta_dp -&gt; theta</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>            
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nt)</span>
     <span style="color: #f8f8f2">enddo</span>

     <span style="color: #75715e">! finally update w at the surface: </span>
     <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,nlevp,nt)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,nt)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">g</span>
  <span style="color: #f8f8f2">enddo</span>


  <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&#39;advance_physical_vis&#39;</span><span style="color: #f8f8f2">)</span>

  <span style="color: #66d9ef">end subroutine </span><span style="color: #f8f8f2">advance_physical_vis</span>





<span style="color: #75715e">!============================ stiff and or non-stiff ============================================</span>

 <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">compute_andor_apply_rhs(np1,nm1,n0,qn0,dt2,elem,hvcoord,hybrid,&amp;</span>
       <span style="color: #f8f8f2">deriv,nets,nete,compute_diagnostics,eta_ave_w,scale1,scale2,scale3)</span>
  <span style="color: #75715e">! ===================================</span>
  <span style="color: #75715e">! compute the RHS, accumulate into u(np1) and apply DSS</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">!   u(np1) = scale3*u(nm1) + dt2*DSS[ nonstiffRHS(u(n0))*scale1 + stiffRHS(un0)*scale2 ]</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">! This subroutine was orgininally called to compute a leapfrog timestep</span>
  <span style="color: #75715e">! but by adjusting np1,nm1,n0 and dt2, many other timesteps can be</span>
  <span style="color: #75715e">! accomodated.  For example, setting nm1=np1=n0 this routine will</span>
  <span style="color: #75715e">! take a forward euler step, overwriting the input with the output.</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">!    qn0 = timelevel used to access Qdp() in order to compute virtual Temperature</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">! ===================================</span>

  <span style="color: #66d9ef">integer</span><span style="color: #f8f8f2">,</span>              <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">np1,nm1,n0,qn0,nets,nete</span>
  <span style="color: #66d9ef">real</span><span style="color: #f92672">*</span><span style="color: #ae81ff">8</span><span style="color: #f8f8f2">,</span>               <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dt2</span>
  <span style="color: #66d9ef">logical</span><span style="color: #f8f8f2">,</span>              <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">compute_diagnostics</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hvcoord_t),</span>     <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hybrid_t),</span>      <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hybrid</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(element_t),</span>     <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout),</span> <span style="color: #66d9ef">target</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">elem(:)</span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(derivative_t),</span>  <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">deriv</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">eta_ave_w,scale1,scale2,scale3</span>  <span style="color: #75715e">! weighting for eta_dot_dpdn mean flux, scale of unm1</span>

  <span style="color: #75715e">! local</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">pointer</span><span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(:,:,:)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">phi_i</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">pointer</span><span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(:,:,:)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp3d</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">pointer</span><span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(:,:,:)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtheta_dp</span>
   
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtheta(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtheta_i(np,np,nlevp)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">omega_i(np,np,nlevp)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">omega(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vort(np,np,nlev)</span>           <span style="color: #75715e">! vorticity</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">divdp(np,np,nlev)</span>     
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">phi(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pnh(np,np,nlev)</span>               <span style="color: #75715e">! nh (nonydro) pressure</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp3d_i(np,np,nlevp)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">exner(np,np,nlev)</span>         <span style="color: #75715e">! exner nh pressure</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dpnh_dp_i(np,np,nlevp)</span>    <span style="color: #75715e">! dpnh / dp3d at interfaces</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">eta_dot_dpdn(np,np,nlevp)</span>  <span style="color: #75715e">! vertical velocity at interfaces</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">KE(np,np,nlev)</span>             <span style="color: #75715e">! Kinetic energy</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">gradexner(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev)</span>    <span style="color: #75715e">! grad(p^kappa)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">gradphinh_i(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlevp)</span> <span style="color: #75715e">! gradphi at interfaces</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">mgrad(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev)</span>        <span style="color: #75715e">! gradphi metric term at cell centers</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">gradKE(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev)</span>       <span style="color: #75715e">! grad(0.5 u^T u )</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">wvor(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev)</span>         <span style="color: #75715e">! w vorticity term</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">gradw_i(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlevp)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">v_gradw_i(np,np,nlevp)</span>     
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">v_gradtheta(np,np,nlev)</span>     
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">v_theta(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">div_v_theta(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">v_gradphinh_i(np,np,nlevp)</span> <span style="color: #75715e">! v*gradphi at interfaces</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">v_i(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlevp)</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">v_vadv(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev)</span>     <span style="color: #75715e">! velocity vertical advection</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">theta_vadv(np,np,nlev)</span>   <span style="color: #75715e">! w,phi, theta  vertical advection term</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">w_vadv_i(np,np,nlevp)</span>      <span style="color: #75715e">! w,phi, theta  vertical advection term</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">phi_vadv_i(np,np,nlevp)</span>    <span style="color: #75715e">! w,phi, theta  vertical advection term</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtens1(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtens2(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">stens(np,np,nlev,</span><span style="color: #ae81ff">3</span><span style="color: #f8f8f2">)</span> <span style="color: #75715e">! tendencies w,phi,theta</span>
                                               <span style="color: #75715e">! w,phi tendencies not computed at nlevp</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">w_tens(np,np,nlevp)</span>  <span style="color: #75715e">! need to update w at surface as well</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">theta_tens(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">phi_tens(np,np,nlevp)</span>
                                               

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pi(np,np,nlev)</span>                <span style="color: #75715e">! hydrostatic pressure</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pi_i(np,np,nlevp)</span>             <span style="color: #75715e">! hydrostatic pressure interfaces</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np,nlev)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vgrad_p</span>

  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span>  <span style="color: #f8f8f2">temp(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span>  <span style="color: #f8f8f2">vtemp(np,np,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev)</span>       <span style="color: #75715e">! generic gradient storage</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">dimension</span><span style="color: #f8f8f2">(np,np)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">sdot_sum</span> <span style="color: #75715e">! temporary field</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span>  <span style="color: #f8f8f2">v1,v2,w,d_eta_dot_dpdn_dn,</span> <span style="color: #f8f8f2">T0</span>
  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">i,j,k,kptr,ie,</span> <span style="color: #f8f8f2">nlyr_tot</span>

  <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&#39;compute_andor_apply_rhs&#39;</span><span style="color: #f8f8f2">)</span>

  <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">nlyr_tot</span><span style="color: #f92672">=</span><span style="color: #ae81ff">4</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>        <span style="color: #75715e">! dont bother to dss w_i and phinh_i</span>
  <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">nlyr_tot</span><span style="color: #f92672">=</span><span style="color: #ae81ff">5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlevp</span>  <span style="color: #75715e">! total amount of data for DSS</span>
  <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     </span>
<span style="color: #66d9ef">  do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
     <span style="color: #f8f8f2">dp3d</span>  <span style="color: #f92672">=&gt;</span> <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,:,n0)</span>
     <span style="color: #f8f8f2">vtheta_dp</span>  <span style="color: #f92672">=&gt;</span> <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,:,n0)</span>
     <span style="color: #f8f8f2">vtheta(:,:,:)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">vtheta_dp(:,:,:)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d(:,:,:)</span>
     <span style="color: #f8f8f2">phi_i</span> <span style="color: #f92672">=&gt;</span> <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,:,n0)</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">ENERGY_DIAGNOSTICS</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
        <span style="color: #75715e">! check w b.c.</span>
        <span style="color: #f8f8f2">temp(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span>  <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">g</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
           <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">abs(temp(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,nlevp,n0))</span> <span style="color: #f92672">&gt;</span><span style="color: #960050; background-color: #1e0010">1</span><span style="color: #f8f8f2">e</span><span style="color: #f92672">-</span><span style="color: #ae81ff">10</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">              write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;WARNING:CAAR w(n0) does not satisfy b.c.&#39;</span><span style="color: #f8f8f2">,ie,i,j,k</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;val1 = &#39;</span><span style="color: #f8f8f2">,temp(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;val2 = &#39;</span><span style="color: #f8f8f2">,elem(ie)%state%w_i(i,j,nlevp,n0)</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;diff: &#39;</span><span style="color: #f8f8f2">,temp(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,nlevp,n0)</span>
           <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">enddo</span>
        <span style="color: #f8f8f2">enddo</span>
        <span style="color: #75715e">! w boundary condition. just in case:</span>
        <span style="color: #75715e">!elem(ie)%state%w_i(:,:,nlevp,n0) = (elem(ie)%state%v(:,:,1,nlev,n0)*elem(ie)%derived%gradphis(:,:,1) + &amp;</span>
        <span style="color: #75715e">!     elem(ie)%state%v(:,:,2,nlev,n0)*elem(ie)%derived%gradphis(:,:,2))/g</span>

        <span style="color: #75715e">! check for layer spacing &lt;= 1m</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
           <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">((phi_i(i,j,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">phi_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span> <span style="color: #f92672">&lt;</span> <span style="color: #f8f8f2">g)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">              write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;WARNING:CAAR before ADV, delta z &lt; 1m. ie,i,j,k=&#39;</span><span style="color: #f8f8f2">,ie,i,j,k</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;phi(i,j,k)=  &#39;</span><span style="color: #f8f8f2">,phi_i(i,j,k)</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;phi(i,j,k+1)=&#39;</span><span style="color: #f8f8f2">,phi_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
           <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">enddo</span>
        <span style="color: #f8f8f2">enddo</span>
        <span style="color: #f8f8f2">enddo</span>
     <span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">     call </span><span style="color: #f8f8f2">pnh_and_exner_from_eos(hvcoord,vtheta_dp,dp3d,phi_i,pnh,exner,dpnh_dp_i,caller</span><span style="color: #f92672">=</span><span style="color: #e6db74">&#39;CAAR&#39;</span><span style="color: #f8f8f2">)</span>

     <span style="color: #f8f8f2">dp3d_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">dp3d(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
     <span style="color: #f8f8f2">dp3d_i(:,:,nlevp)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">dp3d(:,:,nlev)</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">dp3d_i(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">(dp3d(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">dp3d(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
     <span style="color: #66d9ef">end do</span>

     <span style="color: #75715e">! special averaging for velocity for energy conservation</span>
     <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span>  
     <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlevp)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">:</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,n0)</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(dp3d(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">dp3d(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span> <span style="color: #f8f8f2">)</span> <span style="color: #f92672">/</span> <span style="color: #f8f8f2">(</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d_i(:,:,k))</span>
        <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(dp3d(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">dp3d(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span> <span style="color: #f8f8f2">)</span> <span style="color: #f92672">/</span> <span style="color: #f8f8f2">(</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d_i(:,:,k))</span>
     <span style="color: #66d9ef">end do</span>
<span style="color: #66d9ef">     </span>
<span style="color: #66d9ef">     if</span> <span style="color: #f8f8f2">(theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nlev,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span>          <span style="color: #75715e">! traditional Hydrostatic integral</span>
           <span style="color: #f8f8f2">phi_i(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">phi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">Rgas</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta_dp(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">exner(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">pnh(:,:,k)</span>
        <span style="color: #f8f8f2">enddo</span>
        <span style="color: #75715e">! in H mode, ignore w contibutions to KE term</span>
        <span style="color: #75715e">! set to zero so H and NH can share code and reduce if statements</span>
        <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,:,n0)</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>   
     <span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">     do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">phi(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(phi_i(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">phi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>  <span style="color: #75715e">! for diagnostics</span>

        <span style="color: #75715e">! ================================</span>
        <span style="color: #75715e">! Accumulate mean Vel_rho flux in vn0</span>
        <span style="color: #75715e">! ================================</span>
        <span style="color: #f8f8f2">vtemp(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(:,:,k)</span>
        <span style="color: #f8f8f2">vtemp(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(:,:,k)</span>
        <span style="color: #f8f8f2">elem(ie)%derived%vn0(:,:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%derived%vn0(:,:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtemp(:,:,:,k)</span>

        <span style="color: #f8f8f2">divdp(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">divergence_sphere(vtemp(:,:,:,k),deriv,elem(ie))</span>
        <span style="color: #f8f8f2">vort(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vorticity_sphere(elem(ie)%state%v(:,:,:,k,n0),deriv,elem(ie))</span>
     <span style="color: #f8f8f2">enddo</span>

      
     <span style="color: #75715e">! Compute omega =  Dpi/Dt   Used only as a DIAGNOSTIC</span>
     <span style="color: #f8f8f2">pi_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">hvcoord%hyai(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">hvcoord%ps0</span>
     <span style="color: #f8f8f2">omega_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">pi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">pi_i(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dp3d(:,:,k)</span>
        <span style="color: #f8f8f2">omega_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">omega_i(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">divdp(:,:,k)</span>
     <span style="color: #f8f8f2">enddo</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
        <span style="color: #f8f8f2">pi(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">(pi_i(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">pi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">pi(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">pi_i(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dp3d(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">vtemp(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(</span> <span style="color: #f8f8f2">pi(:,:,k),</span> <span style="color: #f8f8f2">deriv,</span> <span style="color: #f8f8f2">elem(ie)%Dinv);</span>
        <span style="color: #f8f8f2">vgrad_p(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtemp(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtemp(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span>
        <span style="color: #f8f8f2">omega(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(vgrad_p(:,:,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">omega_i(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">omega_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span> 
     <span style="color: #f8f8f2">enddo</span>        

     <span style="color: #75715e">! ==================================================</span>
     <span style="color: #75715e">! Compute eta_dot_dpdn</span>
     <span style="color: #75715e">! save sdot_sum as this is the -RHS of ps_v equation</span>
     <span style="color: #75715e">! ==================================================</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(rsplit</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
        <span style="color: #75715e">! VERTICALLY LAGRANGIAN:   no vertical motion</span>
        <span style="color: #f8f8f2">eta_dot_dpdn</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">w_vadv_i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">phi_vadv_i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">theta_vadv</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">v_vadv</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
     <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">sdot_sum</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
           <span style="color: #75715e">! ==================================================</span>
           <span style="color: #75715e">! add this term to PS equation so we exactly conserve dry mass</span>
           <span style="color: #75715e">! ==================================================</span>
           <span style="color: #f8f8f2">sdot_sum(:,:)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">sdot_sum(:,:)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">divdp(:,:,k)</span>
           <span style="color: #f8f8f2">eta_dot_dpdn(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">sdot_sum(:,:)</span>
        <span style="color: #66d9ef">end do</span>


        <span style="color: #75715e">! ===========================================================</span>
        <span style="color: #75715e">! at this point, eta_dot_dpdn contains integral_etatop^eta[ divdp ]</span>
        <span style="color: #75715e">! compute at interfaces:</span>
        <span style="color: #75715e">!    eta_dot_dpdn = -dp/dt - integral_etatop^eta[ divdp ]</span>
        <span style="color: #75715e">! for reference: at mid layers we have:</span>
        <span style="color: #75715e">!    omega = v grad p  - integral_etatop^eta[ divdp ]</span>
        <span style="color: #75715e">! ===========================================================</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span>
           <span style="color: #f8f8f2">eta_dot_dpdn(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">hvcoord%hybi(k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">sdot_sum(:,:)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">eta_dot_dpdn(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
        <span style="color: #66d9ef">end do</span>

<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">eta_dot_dpdn(:,:,</span><span style="color: #ae81ff">1</span>     <span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">eta_dot_dpdn(:,:,nlevp)</span>  <span style="color: #f92672">=</span> <span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">vtheta_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span>       <span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">vtheta_i(:,:,nlevp)</span> <span style="color: #f92672">=</span>   <span style="color: #ae81ff">0</span>


        <span style="color: #75715e">! ===========================================================</span>
        <span style="color: #75715e">! Compute vertical advection of v from eq. CCM2 (3.b.1)</span>
        <span style="color: #75715e">! ==============================================</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">preq_vertadv_v1(elem(ie)%state%v(:,:,:,:,n0),eta_dot_dpdn,dp3d,v_vadv)</span>

        <span style="color: #75715e">! compute (cp*theta) at interfaces</span>
        <span style="color: #75715e">! for energy conservation, use averaging consistent with EOS</span>
        <span style="color: #75715e">! dont bother to compute at surface and top since it will be multiplied by eta-dot</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">if </span><span style="color: #ae81ff">0</span>           
           <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>  <span style="color: #75715e">! simple averaging</span>
              <span style="color: #f8f8f2">vtheta_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(vtheta(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">vtheta(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
           <span style="color: #f8f8f2">enddo</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
           <span style="color: #75715e">! E conserving average, but much more dissipative</span>
           <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
              <span style="color: #f8f8f2">vtheta_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f92672">-</span><span style="color: #f8f8f2">dpnh_dp_i(:,:,k)</span><span style="color: #f92672">*</span> <span style="color: #f8f8f2">((phi(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">phi(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">&amp;</span>
                                                    <span style="color: #f8f8f2">(exner(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">exner(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span> <span style="color: #f92672">/</span> <span style="color: #f8f8f2">Cp)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">              </span><span style="color: #f8f8f2">vtheta_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f92672">-</span><span style="color: #f8f8f2">dpnh_dp_i(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(phi(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">phi(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f8f8f2">(exner(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">exner(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span> <span style="color: #f92672">/</span> <span style="color: #f8f8f2">Cp</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">enddo</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif           </span>



<span style="color: #66d9ef">        do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
           <span style="color: #75715e">! average interface quantity to midpoints:</span>
           <span style="color: #f8f8f2">temp(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">((</span> <span style="color: #f8f8f2">eta_dot_dpdn(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">eta_dot_dpdn(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">(elem(ie)%state%w_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,n0))</span>
           
           <span style="color: #75715e">! theta vadv term at midoints</span>
           <span style="color: #f8f8f2">theta_vadv(:,:,k)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">eta_dot_dpdn(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">eta_dot_dpdn(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta_i(:,:,k)</span>
        <span style="color: #f8f8f2">enddo</span>
        <span style="color: #75715e">! compute ave( ave(etadot) d/dx )</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>
           <span style="color: #f8f8f2">w_vadv_i(:,:,k)</span>  <span style="color: #f92672">=</span><span style="color: #f8f8f2">(temp(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">temp(:,:,k))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
           <span style="color: #f8f8f2">phi_vadv_i(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">eta_dot_dpdn(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(phi(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">phi(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span>
        <span style="color: #66d9ef">end do</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">w_vadv_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">temp(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
        <span style="color: #f8f8f2">w_vadv_i(:,:,nlevp)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">temp(:,:,nlev)</span>
        <span style="color: #f8f8f2">phi_vadv_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">phi_vadv_i(:,:,nlevp)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0</span>

        <span style="color: #75715e">! final form of SB81 vertical advection operator:</span>
        <span style="color: #f8f8f2">w_vadv_i</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">w_vadv_i</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d_i</span>
        <span style="color: #f8f8f2">phi_vadv_i</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">phi_vadv_i</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d_i</span>
     <span style="color: #66d9ef">endif</span>


     <span style="color: #75715e">! ================================</span>
     <span style="color: #75715e">! accumulate mean vertical flux:</span>
     <span style="color: #75715e">! ================================</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>  <span style="color: #75715e">!  Loop index added (AAM)</span>
        <span style="color: #f8f8f2">elem(ie)%derived%eta_dot_dpdn(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%eta_dot_dpdn(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">eta_dot_dpdn(:,:,k)</span>
        <span style="color: #f8f8f2">elem(ie)%derived%omega_p(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%omega_p(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">omega(:,:,k)</span>
     <span style="color: #f8f8f2">enddo</span>
     <span style="color: #f8f8f2">elem(ie)%derived%eta_dot_dpdn(:,:,nlev</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%eta_dot_dpdn(:,:,nlev</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">eta_ave_w</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">eta_dot_dpdn(:,:,nlev</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>

     <span style="color: #75715e">! ================================================</span>
     <span style="color: #75715e">! w,phi tendencies including surface</span>
     <span style="color: #75715e">! ================================================  </span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #75715e">! compute gradphi at interfaces and then average to levels</span>
        <span style="color: #f8f8f2">gradphinh_i(:,:,:,k)</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(phi_i(:,:,k),deriv,elem(ie)%Dinv)</span>   
           
        <span style="color: #f8f8f2">gradw_i(:,:,:,k)</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(elem(ie)%state%w_i(:,:,k,n0),deriv,elem(ie)%Dinv)</span>
        <span style="color: #f8f8f2">v_gradw_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradw_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradw_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span>
        <span style="color: #75715e">! w - tendency on interfaces </span>
        <span style="color: #f8f8f2">w_tens(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">w_vadv_i(:,:,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">v_gradw_i(:,:,k))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale1</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">scale2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(</span><span style="color: #ae81ff">1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">dpnh_dp_i(:,:,k)</span> <span style="color: #f8f8f2">)</span>

        <span style="color: #75715e">! phi - tendency on interfaces</span>
        <span style="color: #75715e">! vtemp(:,:,:,k) = gradphinh_i(:,:,:,k) + &amp;</span>
        <span style="color: #75715e">!    (scale2-1)*hvcoord%hybi(k)*elem(ie)%derived%gradphis(:,:,:)</span>
        <span style="color: #f8f8f2">v_gradphinh_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradphinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f92672">+</span><span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradphinh_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> 
        <span style="color: #f8f8f2">phi_tens(:,:,k)</span> <span style="color: #f92672">=</span>  <span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">phi_vadv_i(:,:,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">v_gradphinh_i(:,:,k))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale1</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f92672">+</span> <span style="color: #f8f8f2">scale2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,n0)</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(scale1</span><span style="color: #f92672">/=</span><span style="color: #f8f8f2">scale2)</span> <span style="color: #66d9ef">then</span>
           <span style="color: #75715e">! add imex phi_h splitting </span>
           <span style="color: #75715e">! use approximate phi_h = hybi*phis </span>
           <span style="color: #75715e">! could also use true hydrostatic pressure, but this requires extra DSS in dirk()</span>
           <span style="color: #f8f8f2">phi_tens(:,:,k)</span> <span style="color: #f92672">=</span>  <span style="color: #f8f8f2">phi_tens(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">(scale1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">scale2)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(&amp;</span>
                <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">hvcoord%hybi(k)</span>
        <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     end do</span>


     <span style="color: #75715e">! k =nlevp case, all terms in the imex methods are treated explicitly at the boundary</span>
     <span style="color: #f8f8f2">k</span> <span style="color: #f92672">=</span><span style="color: #f8f8f2">nlevp</span> 
    <span style="color: #75715e">! compute gradphi at interfaces and then average to levels</span>
    <span style="color: #f8f8f2">gradphinh_i(:,:,:,k)</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(phi_i(:,:,k),deriv,elem(ie)%Dinv)</span>
    <span style="color: #f8f8f2">gradw_i(:,:,:,k)</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(elem(ie)%state%w_i(:,:,k,n0),deriv,elem(ie)%Dinv)</span>
    <span style="color: #f8f8f2">v_gradw_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradw_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradw_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span>
    <span style="color: #75715e">! w - tendency on interfaces</span>
    <span style="color: #f8f8f2">w_tens(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">w_vadv_i(:,:,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">v_gradw_i(:,:,k))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale1</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(</span><span style="color: #ae81ff">1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">dpnh_dp_i(:,:,k)</span> <span style="color: #f8f8f2">)</span>

    <span style="color: #75715e">! phi - tendency on interfaces</span>
    <span style="color: #f8f8f2">v_gradphinh_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradphinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
     <span style="color: #f92672">+</span><span style="color: #f8f8f2">v_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradphinh_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span>
    <span style="color: #f8f8f2">phi_tens(:,:,k)</span> <span style="color: #f92672">=</span>  <span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">phi_vadv_i(:,:,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">v_gradphinh_i(:,:,k))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale1</span> <span style="color: #f8f8f2">&amp;</span>
    <span style="color: #f92672">+</span> <span style="color: #f8f8f2">scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,n0)</span>
    




     <span style="color: #75715e">! ================================================                                                                 </span>
     <span style="color: #75715e">! v1,v2 tendencies:                                                                                          </span>
     <span style="color: #75715e">! ================================================           </span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #75715e">! theta - tendency on levels</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(theta_advect_form</span><span style="color: #f92672">==</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">v_theta(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta_dp(:,:,k)</span>
           <span style="color: #f8f8f2">v_theta(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta_dp(:,:,k)</span>
           <span style="color: #f8f8f2">div_v_theta(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">divergence_sphere(v_theta(:,:,:,k),deriv,elem(ie))</span>
        <span style="color: #66d9ef">else</span>
           <span style="color: #75715e">! alternate form, non-conservative, better HS topography results</span>
           <span style="color: #f8f8f2">v_theta(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(vtheta(:,:,k),deriv,elem(ie)%Dinv)</span>
           <span style="color: #f8f8f2">div_v_theta(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtheta(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">divdp(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">dp3d(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">v_theta(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">dp3d(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">v_theta(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> 
        <span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
        <span style="color: #f8f8f2">theta_tens(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">theta_vadv(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">div_v_theta(:,:,k))</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">theta_tens(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">theta_vadv(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">div_v_theta(:,:,k))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale1</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

        <span style="color: #75715e">! w vorticity correction term</span>
        <span style="color: #f8f8f2">temp(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%state%w_i(:,:,k,n0)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
        <span style="color: #f8f8f2">wvor(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(temp(:,:,k),deriv,elem(ie)%Dinv)</span>
        <span style="color: #f8f8f2">wvor(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">wvor(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(elem(ie)%state%w_i(:,:,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradw_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradw_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
        <span style="color: #f8f8f2">wvor(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">wvor(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(elem(ie)%state%w_i(:,:,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradw_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradw_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>

        <span style="color: #f8f8f2">KE(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
        <span style="color: #f8f8f2">gradKE(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(KE(:,:,k),deriv,elem(ie)%Dinv)</span>
        <span style="color: #f8f8f2">gradexner(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(exner(:,:,k),deriv,elem(ie)%Dinv)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">if </span><span style="color: #ae81ff">0</span>
        <span style="color: #75715e">! another form: (good results in dcmip2012 test2.0)  max=0.195</span>
        <span style="color: #75715e">! but bad results with HS topo</span>
        <span style="color: #75715e">!  grad(exner) =( grad(theta*exner) - exner*grad(theta))/theta</span>
        <span style="color: #f8f8f2">vtemp(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(vtheta(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">exner(:,:,k),deriv,elem(ie)%Dinv)</span>
        <span style="color: #f8f8f2">v_theta(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(vtheta(:,:,k),deriv,elem(ie)%Dinv)</span>
        <span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(vtemp(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">exner(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">v_theta(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">vtheta(:,:,k)</span>
        <span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(vtemp(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">exner(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">v_theta(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">vtheta(:,:,k)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">if </span><span style="color: #ae81ff">0</span>
        <span style="color: #75715e">! entropy form: dcmip2012 test2.0 best: max=0.130  (0.124 with conservation form theta)</span>
        <span style="color: #f8f8f2">vtemp(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(vtheta(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">exner(:,:,k),deriv,elem(ie)%Dinv)</span>
        <span style="color: #f8f8f2">v_theta(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(log(vtheta(:,:,k)),deriv,elem(ie)%Dinv)</span>
        <span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(vtemp(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">exner(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">v_theta(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">vtheta(:,:,k)</span>
        <span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(vtemp(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">exner(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">v_theta(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">vtheta(:,:,k)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">if </span><span style="color: #ae81ff">0</span>
        <span style="color: #75715e">! another form:  terrible results in dcmip2012 test2.0</span>
        <span style="color: #75715e">! grad(exner) = grad(p) * kappa * exner / p</span>
        <span style="color: #f8f8f2">gradexner(:,:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradient_sphere(pnh(:,:,k),deriv,elem(ie)%Dinv)</span>
        <span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(Rgas</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">Cp)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">exner(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">pnh(:,:,k)</span>
        <span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(Rgas</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">Cp)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">exner(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">pnh(:,:,k)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

        <span style="color: #75715e">! special averaging of dpnh/dpi grad(phi) for E conservation</span>
        <span style="color: #f8f8f2">mgrad(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(dpnh_dp_i(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradphinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
              <span style="color: #f8f8f2">dpnh_dp_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradphinh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
        <span style="color: #f8f8f2">mgrad(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(dpnh_dp_i(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradphinh_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
              <span style="color: #f8f8f2">dpnh_dp_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradphinh_i(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>

        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(pgrad_correction</span><span style="color: #f92672">==</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">T0</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">TREF</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">tref_lapse_rate</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">TREF</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">Cp</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">g</span>     <span style="color: #75715e">! = 97  </span>
           <span style="color: #f8f8f2">vtemp(:,:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">gradient_sphere(log(exner(:,:,k)),deriv,elem(ie)%Dinv)</span>
           <span style="color: #f8f8f2">mgrad(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">mgrad(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">T0</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(vtemp(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">exner(:,:,k))</span>
           <span style="color: #f8f8f2">mgrad(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">mgrad(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">T0</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(vtemp(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">gradexner(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">exner(:,:,k))</span>
        <span style="color: #66d9ef">endif</span>


<span style="color: #66d9ef">        do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
           <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
              <span style="color: #f8f8f2">v1</span>     <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span>
              <span style="color: #f8f8f2">v2</span>     <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
              <span style="color: #f8f8f2">vtens1(i,j,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradexner(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
                                <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(v_vadv(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">gradKE(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k))</span> <span style="color: #f8f8f2">&amp;</span>
                                <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(mgrad(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">wvor(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k))</span>    <span style="color: #f8f8f2">&amp;</span>
                                <span style="color: #f92672">+</span> <span style="color: #f8f8f2">v2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%fcor(i,j)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">vort(i,j,k))</span> <span style="color: #f8f8f2">)</span>

              <span style="color: #f8f8f2">vtens2(i,j,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradexner(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
                                <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(v_vadv(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">gradKE(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k))</span> <span style="color: #f8f8f2">&amp;</span>
                                <span style="color: #f92672">-</span> <span style="color: #f8f8f2">(mgrad(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">wvor(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k))</span>    <span style="color: #f8f8f2">&amp;</span>
                                <span style="color: #f92672">-</span> <span style="color: #f8f8f2">v1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%fcor(i,j)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">vort(i,j,k))</span> <span style="color: #f8f8f2">)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">              </span><span style="color: #f8f8f2">vtens1(i,j,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">v_vadv(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f92672">+</span> <span style="color: #f8f8f2">v2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%fcor(i,j)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">vort(i,j,k))</span>        <span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f92672">-</span> <span style="color: #f8f8f2">gradKE(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">mgrad(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f92672">-</span><span style="color: #f8f8f2">Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradexner(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)&amp;</span>
                  <span style="color: #f92672">-</span><span style="color: #f8f8f2">wvor(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale1</span>


              <span style="color: #f8f8f2">vtens2(i,j,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">v_vadv(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f92672">-</span> <span style="color: #f8f8f2">v1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%fcor(i,j)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">vort(i,j,k))</span> <span style="color: #f8f8f2">&amp;</span>
                   <span style="color: #f92672">-</span> <span style="color: #f8f8f2">gradKE(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">mgrad(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f92672">-</span><span style="color: #f8f8f2">Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradexner(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f92672">-</span><span style="color: #f8f8f2">wvor(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale1</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">           end do</span>
<span style="color: #66d9ef">        end do     </span>
<span style="color: #66d9ef">     end do</span> 



     
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">ENERGY_DIAGNOSTICS</span>
     <span style="color: #75715e">! =========================================================</span>
     <span style="color: #75715e">! diagnostics. not performance critical, dont thread</span>
     <span style="color: #75715e">! =========================================================</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(compute_diagnostics)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">elem(ie)%accum%KEu_horiz1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%KEu_horiz2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%KEu_vert1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%KEu_vert2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz3</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%KEw_vert1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%KEw_vert2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>

        <span style="color: #f8f8f2">elem(ie)%accum%PEhoriz1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%PEhoriz2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%IEvert1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%IEvert2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%PEvert1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%PEvert2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%T01</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%T2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%S1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%S2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%P1</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
        <span style="color: #f8f8f2">elem(ie)%accum%P2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>

        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span> <span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
          <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
            <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>                
               <span style="color: #f8f8f2">d_eta_dot_dpdn_dn</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">(eta_dot_dpdn(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta_dot_dpdn(i,j,k))</span>
               <span style="color: #75715e">!  Form horiz advection of KE-u</span>
               <span style="color: #f8f8f2">elem(ie)%accum%KEu_horiz1(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEu_horiz1(i,j)</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">dp3d(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradKE(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">gradKE(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f8f8f2">)</span>
               <span style="color: #f8f8f2">elem(ie)%accum%KEu_horiz2(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEu_horiz2(i,j)</span>              <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">KE(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">divdp(i,j,k)</span>
               <span style="color: #75715e">!  Form horiz advection of KE-w</span>
               <span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz1(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz1(i,j)</span><span style="color: #f92672">-</span>   <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">dp3d(i,j,k)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k,n0)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">v_gradw_i(i,j,k)</span>    <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">v_gradw_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
               <span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz2(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz2(i,j)</span><span style="color: #f92672">-</span>   <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">divdp(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(elem(ie)%state%w_i(i,j,k,n0)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f8f8f2">)</span> <span style="color: #f92672">/</span><span style="color: #ae81ff">4</span>
               <span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz3(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEw_horiz3(i,j)</span>   <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">dp3d(i,j,k)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">wvor(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span>  <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">wvor(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k))</span>
               <span style="color: #75715e">!  Form vertical advection of KE-u </span>
               <span style="color: #f8f8f2">elem(ie)%accum%KEu_vert1(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEu_vert1(i,j)</span><span style="color: #f92672">-</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">v_vadv(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span> <span style="color: #f92672">+</span>            <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span> <span style="color: #f92672">*</span><span style="color: #f8f8f2">v_vadv(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(i,j,k)</span>
               <span style="color: #f8f8f2">elem(ie)%accum%KEu_vert2(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEu_vert2(i,j)</span><span style="color: #f92672">-</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #ae81ff">0.5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">((elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0))</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">+</span>                     <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0))</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">d_eta_dot_dpdn_dn</span>
               <span style="color: #75715e">!  Form vertical advection of KE-w</span>
               <span style="color: #f8f8f2">elem(ie)%accum%KEw_vert1(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEw_vert1(i,j)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">dp3d(i,j,k)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(w_vadv_i(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k,n0)</span><span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">w_vadv_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
               
               <span style="color: #f8f8f2">elem(ie)%accum%KEw_vert2(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%KEw_vert2(i,j)</span>      <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">d_eta_dot_dpdn_dn</span><span style="color: #f92672">*</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(</span><span style="color: #ae81ff">.5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k,n0)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #ae81ff">.5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
               
               <span style="color: #75715e">!  Form IEvert1</span>
               <span style="color: #f8f8f2">elem(ie)%accum%IEvert1(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%IEvert1(i,j)</span>      <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">exner(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">theta_vadv(i,j,k)</span>                        
               <span style="color: #75715e">! Form IEvert2 </span>
               <span style="color: #75715e">! here use of dpnh_dp_i on boundry (with incorrect data)</span>
               <span style="color: #75715e">! is harmess becuase eta_dot_dpdn=0</span>
               <span style="color: #f8f8f2">elem(ie)%accum%IEvert2(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%IEvert2(i,j)</span>      <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">dpnh_dp_i(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">eta_dot_dpdn(i,j,k)</span><span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                        <span style="color: #f8f8f2">dpnh_dp_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">eta_dot_dpdn(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">*</span><span style="color: #f8f8f2">(phi_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">phi_i(i,j,k))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
               
               <span style="color: #75715e">!  Form PEhoriz1</span>
               <span style="color: #f8f8f2">elem(ie)%accum%PEhoriz1(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">(elem(ie)%accum%PEhoriz1(i,j))</span>  <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">phi(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">divdp(i,j,k)</span> 
               <span style="color: #75715e">!  Form PEhoriz2</span>
               <span style="color: #f8f8f2">elem(ie)%accum%PEhoriz2(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%PEhoriz2(i,j)</span>    <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">dp3d(i,j,k)</span><span style="color: #f92672">*</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span>                          <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(gradphinh_i(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">gradphinh_i(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>  <span style="color: #f92672">+</span>      <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0)</span><span style="color: #f92672">*</span>                           <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(gradphinh_i(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">gradphinh_i(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>  <span style="color: #f8f8f2">)</span>
               
               <span style="color: #75715e">!  Form PEvert1</span>
               <span style="color: #f8f8f2">elem(ie)%accum%PEvert1(i,j)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%accum%PEvert1(i,j)</span>    <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">phi(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">d_eta_dot_dpdn_dn</span>                                 
               <span style="color: #f8f8f2">elem(ie)%accum%PEvert2(i,j)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%accum%PEvert2(i,j)</span>     <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">dp3d(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(phi_vadv_i(i,j,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">phi_vadv_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
               
               <span style="color: #75715e">!  Form T01</span>
               <span style="color: #f8f8f2">elem(ie)%accum%T01(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%T01(i,j)</span>               <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">(Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(i,j,k,n0))</span>                       <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">*</span><span style="color: #f8f8f2">(gradexner(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,n0)</span> <span style="color: #f92672">+</span>           <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">gradexner(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(i,j,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,n0))</span>              
               <span style="color: #75715e">!  Form S1 </span>
               <span style="color: #f8f8f2">elem(ie)%accum%S1(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%S1(i,j)</span>                 <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f92672">-</span><span style="color: #f8f8f2">Cp</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">exner(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">div_v_theta(i,j,k)</span>

               <span style="color: #75715e">!  Form P1  = -P2  (no reason to compute P2?)</span>
               <span style="color: #f8f8f2">elem(ie)%accum%P1(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%P1(i,j)</span> <span style="color: #f92672">-</span><span style="color: #f8f8f2">g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(i,j,k)</span><span style="color: #f92672">*</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k,n0)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
               <span style="color: #75715e">!  Form P2</span>
               <span style="color: #f8f8f2">elem(ie)%accum%P2(i,j)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%P2(i,j)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(i,j,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k,n0)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
                    <span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,n0)</span> <span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
            <span style="color: #f8f8f2">enddo</span>
         <span style="color: #f8f8f2">enddo</span>
      <span style="color: #f8f8f2">enddo</span>

      <span style="color: #75715e">! these terms are better easier to compute by summing interfaces</span>
      <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>
         <span style="color: #f8f8f2">elem(ie)%accum%T2(:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%T2(:,:)</span><span style="color: #f92672">+</span>                <span style="color: #f8f8f2">&amp;</span>
              <span style="color: #f8f8f2">(g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,n0)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">v_gradphinh_i(:,:,k))</span> <span style="color: #f8f8f2">&amp;</span>
               <span style="color: #f92672">*</span> <span style="color: #f8f8f2">dpnh_dp_i(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d_i(:,:,k)</span>
      <span style="color: #f8f8f2">enddo</span>
      <span style="color: #75715e">! boundary terms</span>
      <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlevp,nlev</span>
         <span style="color: #f8f8f2">elem(ie)%accum%T2(:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%T2(:,:)</span><span style="color: #f92672">+</span>                <span style="color: #f8f8f2">&amp;</span>
           <span style="color: #f8f8f2">(g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,n0)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">v_gradphinh_i(:,:,k))</span> <span style="color: #f8f8f2">&amp;</span>
           <span style="color: #f92672">*</span> <span style="color: #f8f8f2">dpnh_dp_i(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d_i(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
      <span style="color: #f8f8f2">enddo</span>
      <span style="color: #75715e">! boundary term is incorrect.  save the term so we can correct it</span>
      <span style="color: #75715e">! once we have coorect value of dpnh_dp_i:</span>
      <span style="color: #f8f8f2">elem(ie)%accum%T2_nlevp_term(:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">&amp;</span>
           <span style="color: #f8f8f2">(g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,nlevp,n0)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">v_gradphinh_i(:,:,nlevp))</span> <span style="color: #f8f8f2">&amp;</span>
           <span style="color: #f92672">*</span> <span style="color: #f8f8f2">dp3d_i(:,:,nlevp)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>

   <span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>


<span style="color: #66d9ef">     do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
        <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale3)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens1(:,:,k)</span>
        <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale3)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f92672">+</span>  <span style="color: #f8f8f2">(scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens2(:,:,k)</span>
        <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale3)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">theta_tens(:,:,k)</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,np1)</span>    <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale3)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nm1)</span>   <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">w_tens(:,:,k)</span>
           <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,np1)</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale3)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">phi_tens(:,:,k)</span>
        <span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">scale3)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nm1)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">(scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:))</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(divdp(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(eta_dot_dpdn(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta_dot_dpdn(:,:,k)))</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(scale3</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens1(:,:,k)</span> <span style="color: #f8f8f2">)</span>
        <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(scale3</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f92672">+</span>  <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtens2(:,:,k)</span> <span style="color: #f8f8f2">)</span>
        <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(scale3</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,nm1)</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">theta_tens(:,:,k))</span>

        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,np1)</span>    <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(scale3</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nm1)</span>   <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">w_tens(:,:,k))</span>
           <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,np1)</span>   <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(scale3</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,nm1)</span> <span style="color: #f8f8f2">&amp;</span> 
                <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">phi_tens(:,:,k))</span>
        <span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(scale3</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,nm1)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(divdp(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">eta_dot_dpdn(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">eta_dot_dpdn(:,:,k)))</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">enddo</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nlevp</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
        <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,np1)</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">scale3)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nm1)</span>   <span style="color: #f8f8f2">&amp;</span>
        <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">w_tens(:,:,k)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,np1)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%spheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(scale3</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,nm1)</span>   <span style="color: #f8f8f2">&amp;</span>
        <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">w_tens(:,:,k))</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     endif</span>


<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%v(:,:,:,:,np1),</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev,kptr,nlyr_tot)</span>
     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%dp3d(:,:,:,np1),nlev,kptr,</span> <span style="color: #f8f8f2">nlyr_tot)</span>
     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%vtheta_dp(:,:,:,np1),nlev,kptr,nlyr_tot)</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%w_i(:,:,:,np1),nlevp,kptr,nlyr_tot)</span>
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlevp</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%phinh_i(:,:,:,np1),nlev,kptr,nlyr_tot)</span>
     <span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">   end do</span> <span style="color: #75715e">! end do for the ie=nets,nete loop</span>

  <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_startf(</span><span style="color: #e6db74">&#39;caar_bexchV&#39;</span><span style="color: #f8f8f2">)</span>
  <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">bndry_exchangeV(hybrid,edge_g)</span>
  <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&#39;caar_bexchV&#39;</span><span style="color: #f8f8f2">)</span>

  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">ie</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nets,nete</span>
     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%v(:,:,:,:,np1),</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev,kptr,nlyr_tot)</span>
     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">nlev</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%dp3d(:,:,:,np1),nlev,kptr,nlyr_tot)</span>
     <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev</span>
     <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%vtheta_dp(:,:,:,np1),nlev,kptr,nlyr_tot)</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlev</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%w_i(:,:,:,np1),nlevp,kptr,nlyr_tot)</span>
        <span style="color: #f8f8f2">kptr</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">kptr</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">nlevp</span>
        <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">edgeVunpack_nlyr(edge_g,elem(ie)%desc,elem(ie)%state%phinh_i(:,:,:,np1),nlev,kptr,nlyr_tot)</span>
     <span style="color: #66d9ef">endif</span>
      
     <span style="color: #75715e">! ====================================================</span>
     <span style="color: #75715e">! Scale tendencies by inverse mass matrix</span>
     <span style="color: #75715e">! ====================================================</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,np1)</span> <span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%dp3d(:,:,k,np1)</span>
        <span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,np1)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%vtheta_dp(:,:,k,np1)</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,np1)</span>    <span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,np1)</span>
           <span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,np1)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(:,:,k,np1)</span>
        <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,np1)</span>  <span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,k,np1)</span>
        <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,np1)</span>  <span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,k,np1)</span>
     <span style="color: #66d9ef">end do</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nlevp</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode</span> <span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,np1)</span>    <span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%rspheremp(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,k,np1)</span>


     <span style="color: #75715e">! now we can compute the correct dphn_dp_i() at the surface:</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span><span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
        <span style="color: #75715e">! solve for (dpnh_dp_i-1)</span>
        <span style="color: #f8f8f2">dpnh_dp_i(:,:,nlevp)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(</span>  <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">((elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,np1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,np1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">g</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,nlevp,np1))</span> <span style="color: #f92672">/</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">(g</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">**</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">(</span><span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">g))</span>   <span style="color: #f8f8f2">)</span>  <span style="color: #f92672">/</span> <span style="color: #f8f8f2">dt2</span>

        <span style="color: #75715e">! update solution with new dpnh_dp_i value:</span>
        <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,nlevp,np1)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">elem(ie)%state%w_i(:,:,nlevp,np1)</span> <span style="color: #f92672">+</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">g</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(dpnh_dp_i(:,:,nlevp)</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
        <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,np1)</span> <span style="color: #f92672">=</span>  <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,np1)</span> <span style="color: #f92672">-</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(dpnh_dp_i(:,:,nlevp)</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
        <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,np1)</span> <span style="color: #f92672">=</span>  <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,np1)</span> <span style="color: #f92672">-</span><span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">scale1</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dt2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(dpnh_dp_i(:,:,nlevp)</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">ENERGY_DIAGNOSTICS</span>
        <span style="color: #75715e">! add in boundary term to T2 and S2 diagnostics:</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(compute_diagnostics)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           </span><span style="color: #f8f8f2">elem(ie)%accum%T2(:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">elem(ie)%accum%T2(:,:)</span><span style="color: #f92672">+</span>                <span style="color: #f8f8f2">&amp;</span>
                <span style="color: #f8f8f2">elem(ie)%accum%T2_nlevp_term(:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(dpnh_dp_i(:,:,nlevp)</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
           <span style="color: #f8f8f2">elem(ie)%accum%S2(:,:)</span><span style="color: #f92672">=-</span><span style="color: #f8f8f2">elem(ie)%accum%T2(:,:)</span>      
        <span style="color: #66d9ef">endif</span>

        <span style="color: #75715e">! check w b.c.</span>
        <span style="color: #f8f8f2">temp(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span>  <span style="color: #f8f8f2">(elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev,np1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">elem(ie)%state%v(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev,np1)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">elem(ie)%derived%gradphis(:,:,</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">g</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
           <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">abs(temp(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,nlevp,np1))</span> <span style="color: #f92672">&gt;</span><span style="color: #960050; background-color: #1e0010">1</span><span style="color: #f8f8f2">e</span><span style="color: #f92672">-</span><span style="color: #ae81ff">10</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">              write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;WARNING:CAAR w(np1) does not satisfy b.c.&#39;</span><span style="color: #f8f8f2">,ie,i,j,k</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;val1 = &#39;</span><span style="color: #f8f8f2">,temp(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;val2 = &#39;</span><span style="color: #f8f8f2">,elem(ie)%state%w_i(i,j,nlevp,np1)</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;diff: &#39;</span><span style="color: #f8f8f2">,temp(i,j,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%w_i(i,j,nlevp,np1)</span>
           <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">enddo</span>
        <span style="color: #f8f8f2">enddo</span>

        <span style="color: #75715e">! check for layer spacing &lt;= 1m</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
        <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
           <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">((elem(ie)%state%phinh_i(i,j,k,np1)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">elem(ie)%state%phinh_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np1))</span> <span style="color: #f92672">&lt;</span> <span style="color: #f8f8f2">g)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">              write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;WARNING:CAAR after ADV, delta z &lt; 1m. ie,i,j,k=&#39;</span><span style="color: #f8f8f2">,ie,i,j,k</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;phi(i,j,k)=  &#39;</span><span style="color: #f8f8f2">,elem(ie)%state%phinh_i(i,j,k,np1)</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;phi(i,j,k+1)=&#39;</span><span style="color: #f8f8f2">,elem(ie)%state%phinh_i(i,j,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np1)</span>
           <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">enddo</span>
        <span style="color: #f8f8f2">enddo</span>
        <span style="color: #f8f8f2">enddo</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     endif</span>
<span style="color: #66d9ef">     if</span> <span style="color: #f8f8f2">(scale3</span> <span style="color: #f92672">/=</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">       call </span><span style="color: #f8f8f2">limiter_dp3d_k(elem(ie)%state%dp3d(:,:,:,np1),elem(ie)%state%vtheta_dp(:,:,:,np1),&amp;</span>
            <span style="color: #f8f8f2">elem(ie)%spheremp,hvcoord%dp0)</span>
     <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  end do</span>
<span style="color: #66d9ef">  call </span><span style="color: #f8f8f2">t_stopf(</span><span style="color: #e6db74">&#39;compute_andor_apply_rhs&#39;</span><span style="color: #f8f8f2">)</span>

  <span style="color: #66d9ef">end subroutine </span><span style="color: #f8f8f2">compute_andor_apply_rhs</span>


  <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">limiter_dp3d_k(dp3d,vtheta_dp,spheremp,dp0)</span>
  <span style="color: #75715e">! mass conserving column limiter (1D only)</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">! if dp3d &lt; dp3d_thresh*hvcoord%dp0 then apply vertical mixing </span>
  <span style="color: #75715e">! to prevent layer from getting too thin</span>
  <span style="color: #75715e">!</span>
  <span style="color: #75715e">! This is rarely triggered and is mostly for safety when using </span>
  <span style="color: #75715e">! long remap timesteps</span>
  <span style="color: #75715e">!</span>
  <span style="color: #66d9ef">implicit none</span>
<span style="color: #66d9ef">  real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp3d(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtheta_dp(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp0(nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">spheremp(np,np)</span>  <span style="color: #75715e">!  density</span>

  <span style="color: #75715e">! local</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">Qcol(nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">mass,mass_new</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp3d_thresh</span><span style="color: #f92672">=</span><span style="color: #ae81ff">.125</span>
  <span style="color: #66d9ef">logical</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">warn</span>
  <span style="color: #66d9ef">integer </span><span style="color: #f8f8f2">i,j,k</span>

  <span style="color: #75715e">! first check if limter is needed, and print warning</span>
  <span style="color: #f8f8f2">warn</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.</span> 
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">minval(dp3d(:,:,k))</span> <span style="color: #f92672">&lt;</span> <span style="color: #f8f8f2">dp3d_thresh</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp0(k))</span> <span style="color: #66d9ef">then</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
        <span style="color: #75715e">! In bfb unit tests, we use (semi-)random inputs, so we expect to hit this.</span>
        <span style="color: #75715e">! Still, we don&#39;t want to fill up the console output</span>
        <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;WARNING:CAAR: dp3d too small. dt_remap may be too large&#39;</span>
        <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;k,dp3d(k), dp0: &#39;</span><span style="color: #f8f8f2">,k,minval(dp3d(:,:,k)),dp0(k)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">warn</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.true.</span>
     <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  </span><span style="color: #f8f8f2">enddo</span>

  <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(warn)</span> <span style="color: #66d9ef">then</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
    <span style="color: #f8f8f2">vtheta_dp(:,:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtheta_dp(:,:,:)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d(:,:,:)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">    do </span><span style="color: #f8f8f2">j</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">np</span>
       <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">np</span>
          <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">minval(dp3d(i,j,:)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">dp3d_thresh</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp0(:))</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
             <span style="color: #f8f8f2">vtheta_dp(i,j,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtheta_dp(i,j,:)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d(i,j,:)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
             <span style="color: #75715e">! subtract min, multiply in by weights</span>
             <span style="color: #f8f8f2">Qcol(:)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(dp3d(i,j,:)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">dp3d_thresh</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp0(:))</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">spheremp(i,j)</span>
             <span style="color: #f8f8f2">mass</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0</span>
             <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
                <span style="color: #f8f8f2">mass</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">mass</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">Qcol(k)</span>
             <span style="color: #f8f8f2">enddo</span>

             <span style="color: #75715e">! negative mass.  so reduce all postive values to zero</span>
             <span style="color: #75715e">! then increase negative values as much as possible</span>
             <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">mass</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">Qcol</span> <span style="color: #f92672">=</span> <span style="color: #f92672">-</span><span style="color: #f8f8f2">Qcol</span>
             <span style="color: #f8f8f2">mass_new</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0</span>
             <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
                <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">Qcol(k)</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">                   </span><span style="color: #f8f8f2">Qcol(k)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0</span>
                <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">                   </span><span style="color: #f8f8f2">mass_new</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">mass_new</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">Qcol(k)</span>
                <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">             </span><span style="color: #f8f8f2">enddo</span>
             <span style="color: #75715e">! now scale the all positive values to restore mass</span>
             <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">mass_new</span> <span style="color: #f92672">&gt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">Qcol(:)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">Qcol(:)</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(abs(mass)</span> <span style="color: #f92672">/</span> <span style="color: #f8f8f2">mass_new)</span>
             <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">mass</span>     <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">Qcol(:)</span> <span style="color: #f92672">=</span> <span style="color: #f92672">-</span><span style="color: #f8f8f2">Qcol(:)</span>
             <span style="color: #75715e">!</span>
             <span style="color: #f8f8f2">dp3d(i,j,:)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">Qcol(:)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">spheremp(i,j)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dp3d_thresh</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp0(:)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
             <span style="color: #f8f8f2">vtheta_dp(i,j,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtheta_dp(i,j,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(i,j,:)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">          endif</span>
<span style="color: #66d9ef">       </span><span style="color: #f8f8f2">enddo</span>
    <span style="color: #f8f8f2">enddo</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
    <span style="color: #f8f8f2">vtheta_dp(:,:,:)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtheta_dp(:,:,:)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(:,:,:)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  endif</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">if </span><span style="color: #ae81ff">1</span>
  <span style="color: #75715e">! check for theta &lt; 10K                                                                                                       </span>
  <span style="color: #f8f8f2">warn</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.false.</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">minval(vtheta_dp(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">vtheta_thresh</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(:,:,k))</span>   <span style="color: #f92672">&lt;</span>  <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
        <span style="color: #75715e">! In bfb unit tests, we use (semi-)random inputs, so we expect to hit this.</span>
        <span style="color: #75715e">! Still, we don&#39;t want to fill up the console output</span>
        <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;WARNING:CAAR: theta&lt;&#39;</span><span style="color: #f8f8f2">,vtheta_thresh,</span><span style="color: #e6db74">&#39; applying limiter&#39;</span>
        <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(iulog,</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">)</span> <span style="color: #e6db74">&#39;k,vtheta(k): &#39;</span><span style="color: #f8f8f2">,k,minval(vtheta_dp(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d(:,:,k))</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">        </span><span style="color: #f8f8f2">warn</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">.true.</span>
     <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  </span><span style="color: #f8f8f2">enddo</span>
  <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(warn)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">    do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
      <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">np</span>
         <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">np</span>
            <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">(vtheta_dp(i,j,k)</span> <span style="color: #f92672">-</span> <span style="color: #f8f8f2">vtheta_thresh</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(i,j,k))</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">               </span><span style="color: #f8f8f2">vtheta_dp(i,j,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">vtheta_thresh</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">dp3d(i,j,k)</span>
            <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">         </span><span style="color: #f8f8f2">enddo</span>
      <span style="color: #f8f8f2">enddo</span>
    <span style="color: #f8f8f2">enddo</span>
  <span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>




<span style="color: #66d9ef">  end subroutine </span><span style="color: #f8f8f2">limiter_dp3d_k</span>

<span style="color: #66d9ef">end module </span><span style="color: #f8f8f2">prim_advance_mod</span>
</pre></div>

</pre>