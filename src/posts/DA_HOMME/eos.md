---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Plan November 22
  key: eos
lF90ayout: layouts/post.njk
--

<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HAVE_CONFIG_H</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">include</span> <span style="color: #e6db74">&quot;config.h&quot;</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">!  NonHydrostatic Equation of State and inverse EOS routines</span>
<span style="color: #75715e">!  Note: these routines should all be discrete inverses of each other</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">!  pnh_and_exner_from_eos()  Compute nonhydrostatic pressure as a function of </span>
<span style="color: #75715e">!                            potential temperature and geopotential</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">!  phi_from_eos()            Compute geopotential as a function of potential temperature</span>
<span style="color: #75715e">!                            and pressure. use virtual potential temperature for wet phi</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">!  Original version: Mark Taylor 2017/1</span>
<span style="color: #75715e">!  </span>
<span style="color: #75715e">!</span>
<span style="color: #66d9ef">module </span><span style="color: #f8f8f2">eos</span>

  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">dimensions_mod,</span> <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">np,</span> <span style="color: #f8f8f2">nlev,</span> <span style="color: #f8f8f2">nlevp</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">element_mod,</span>    <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">element_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">element_state,</span>  <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">timelevels,</span> <span style="color: #f8f8f2">elem_state_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">hybvcoord_mod,</span>  <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">hvcoord_t</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">kinds,</span>          <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">real_kind</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">parallel_mod,</span>   <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">abortmp</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">physical_constants,</span> <span style="color: #f8f8f2">only</span> <span style="color: #f8f8f2">:</span> <span style="color: #f8f8f2">p0,</span> <span style="color: #f8f8f2">kappa,</span> <span style="color: #f8f8f2">g,</span> <span style="color: #f8f8f2">Rgas</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">control_mod,</span>    <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">theta_hydrostatic_mode</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
  <span style="color: #66d9ef">use </span><span style="color: #f8f8f2">bfb_mod,</span>        <span style="color: #f8f8f2">only:</span> <span style="color: #f8f8f2">bfb_pow</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  implicit none</span>


<span style="color: #66d9ef">contains</span>

<span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">pnh_and_exner_from_eos(hvcoord,vtheta_dp,dp3d,phi_i,pnh,exner,&amp;</span>
     <span style="color: #f8f8f2">dpnh_dp_i,pnh_i_out,caller)</span>
<span style="color: #66d9ef">implicit none</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! Use Equation of State to compute exner pressure, nh presure</span>
<span style="color: #75715e">! hydrostatic EOS:</span>
<span style="color: #75715e">!          compute p, exner  </span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! nonhydrostatic EOS:</span>
<span style="color: #75715e">!      p_over_exner   =  -R  vtheta_dp / (dphi/ds)</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! input:  dp3d, phi, phis, vtheta_dp</span>
<span style="color: #75715e">! output:  pnh, dphn, exner, exner_i, pnh_i</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! NOTE: Exner pressure is defined in terms of p0=1000mb.  Be sure to use global constant p0,</span>
<span style="color: #75715e">! instead of hvcoord%ps0, which is set by CAM to ~1021mb</span>
<span style="color: #75715e">!  </span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hvcoord_t),</span>     <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>  <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>             <span style="color: #75715e">! hybrid vertical coordinate struct</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtheta_dp(np,np,nlev)</span>   
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp3d(np,np,nlev)</span>   
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">phi_i(np,np,nlevp)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pnh(np,np,nlev)</span>        <span style="color: #75715e">! nh nonhyrdo pressure</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dpnh_dp_i(np,np,nlevp)</span> <span style="color: #75715e">! d(pnh) / d(pi)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">exner(np,np,nlev)</span>      <span style="color: #75715e">! exner nh pressure</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out),</span> <span style="color: #66d9ef">optional</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pnh_i_out(np,np,nlevp)</span>  <span style="color: #75715e">! pnh on interfaces</span>
  <span style="color: #66d9ef">character</span><span style="color: #f8f8f2">(len</span><span style="color: #f92672">=*</span><span style="color: #f8f8f2">),</span>      <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in),</span> <span style="color: #66d9ef">optional</span>  <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">caller</span>       <span style="color: #75715e">! name for error</span>

  <span style="color: #75715e">!   local</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dphi(np,np,nlev)</span>
  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">k</span>

  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
     <span style="color: #f8f8f2">dphi(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">phi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">phi_i(:,:,k)</span>
  <span style="color: #f8f8f2">enddo</span>
  <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(present(caller))</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">     call </span><span style="color: #f8f8f2">pnh_and_exner_from_eos2(hvcoord,vtheta_dp,dp3d,dphi,pnh,exner,&amp;</span>
          <span style="color: #f8f8f2">dpnh_dp_i,caller,pnh_i_out)</span>
  <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">     call </span><span style="color: #f8f8f2">pnh_and_exner_from_eos2(hvcoord,vtheta_dp,dp3d,dphi,pnh,exner,&amp;</span>
          <span style="color: #f8f8f2">dpnh_dp_i,</span><span style="color: #e6db74">&#39;not specified&#39;</span><span style="color: #f8f8f2">,pnh_i_out)</span>
  <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  end subroutine </span><span style="color: #f8f8f2">pnh_and_exner_from_eos</span>



<span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">pnh_and_exner_from_eos2(hvcoord,vtheta_dp,dp3d,dphi,pnh,exner,&amp;</span>
     <span style="color: #f8f8f2">dpnh_dp_i,caller,pnh_i_out)</span>
<span style="color: #66d9ef">implicit none</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! Use Equation of State to compute exner pressure, nh presure</span>
<span style="color: #75715e">! hydrostatic EOS:</span>
<span style="color: #75715e">!          compute p, exner  </span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! nonhydrostatic EOS:</span>
<span style="color: #75715e">!      p_over_exner   =  -R  vtheta_dp / (dphi/ds)</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! input:  dp3d, phi, phis, vtheta_dp</span>
<span style="color: #75715e">! output:  pnh, dphn, exner, exner_i, pnh_i</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! NOTE: Exner pressure is defined in terms of p0=1000mb.  Be sure to use global constant p0,</span>
<span style="color: #75715e">! instead of hvcoord%ps0, which is set by CAM to ~1021mb</span>
<span style="color: #75715e">!  </span>
  <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hvcoord_t),</span>     <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>  <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>             <span style="color: #75715e">! hybrid vertical coordinate struct</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtheta_dp(np,np,nlev)</span>   
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp3d(np,np,nlev)</span>   
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dphi(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pnh(np,np,nlev)</span>        <span style="color: #75715e">! nh nonhyrdo pressure</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dpnh_dp_i(np,np,nlevp)</span> <span style="color: #75715e">! d(pnh) / d(pi)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">exner(np,np,nlev)</span>      <span style="color: #75715e">! exner nh pressure</span>
  <span style="color: #66d9ef">character</span><span style="color: #f8f8f2">(len</span><span style="color: #f92672">=*</span><span style="color: #f8f8f2">),</span>      <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>  <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">caller</span>       <span style="color: #75715e">! name for error</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out),</span> <span style="color: #66d9ef">optional</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pnh_i_out(np,np,nlevp)</span>  <span style="color: #75715e">! pnh on interfaces</span>


  <span style="color: #75715e">!   local</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">p_over_exner(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pi(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">exner_i(np,np,nlevp)</span> 
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pnh_i(np,np,nlevp)</span>  
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp3d_i(np,np,nlevp)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">pi_i(np,np,nlevp)</span> 
  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">i,j,k,k2</span>
  <span style="color: #66d9ef">logical</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">ierr</span>


  <span style="color: #75715e">! check for bad state that will crash exponential function below</span>
  <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">    </span><span style="color: #f8f8f2">ierr</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">any(dp3d(:,:,:)</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span>
  <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">    </span><span style="color: #f8f8f2">ierr</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">any(vtheta_dp(:,:,:)</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span>  <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f8f8f2">any(dp3d(:,:,:)</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span> <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f8f8f2">any(dphi(:,:,:)</span> <span style="color: #f92672">&gt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span>
  <span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">  if</span> <span style="color: #f8f8f2">(ierr)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">     print</span> <span style="color: #f92672">*</span><span style="color: #f8f8f2">,</span><span style="color: #e6db74">&#39;bad state in EOS, called from: &#39;</span><span style="color: #f8f8f2">,caller</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">(vtheta_dp(i,j,k)</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">(dp3d(i,j,k)</span><span style="color: #f92672">&lt;</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span>  <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">&amp;</span>
             <span style="color: #f8f8f2">(dphi(i,j,k)</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span>  <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           print</span> <span style="color: #f92672">*</span><span style="color: #f8f8f2">,</span><span style="color: #e6db74">&#39;bad i,j,k=&#39;</span><span style="color: #f8f8f2">,i,j,k</span>
           <span style="color: #66d9ef">print</span> <span style="color: #f92672">*</span><span style="color: #f8f8f2">,</span><span style="color: #e6db74">&#39;vertical column: dphi,dp3d,vtheta_dp&#39;</span>
           <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">,</span><span style="color: #e6db74">&#39;(i3,4f14.4)&#39;</span><span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">k2,dphi(i,j,k2),dp3d(i,j,k2),vtheta_dp(i,j,k2)</span>
           <span style="color: #f8f8f2">enddo</span>
           <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">abortmp(</span><span style="color: #e6db74">&#39;EOS bad state: d(phi), dp3d or vtheta_dp &lt; 0&#39;</span><span style="color: #f8f8f2">)</span>
        <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">enddo</span>
     <span style="color: #f8f8f2">enddo</span>
     <span style="color: #f8f8f2">enddo</span>
  <span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">  if</span> <span style="color: #f8f8f2">(theta_hydrostatic_mode)</span> <span style="color: #66d9ef">then</span>
     <span style="color: #75715e">! hydrostatic pressure</span>
     <span style="color: #f8f8f2">pi_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">hvcoord%hyai(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">hvcoord%ps0</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">pi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">pi_i(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dp3d(:,:,k)</span>
     <span style="color: #f8f8f2">enddo</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">pi(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(pi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">pi_i(:,:,k))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
     <span style="color: #f8f8f2">enddo</span>
     <span style="color: #f8f8f2">exner</span>  <span style="color: #f92672">=</span> <span style="color: #f8f8f2">bfb_pow(pi</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0,kappa)</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">     do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #f8f8f2">pi(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">pi_i(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dp3d(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
     <span style="color: #f8f8f2">enddo</span>
     <span style="color: #f8f8f2">exner</span>  <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(pi</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0)</span><span style="color: #f92672">**</span><span style="color: #f8f8f2">kappa</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>

<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">pnh</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">pi</span> <span style="color: #75715e">! copy hydrostatic pressure into output variable</span>
     <span style="color: #f8f8f2">dpnh_dp_i</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">1</span>
     <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(present(pnh_i_out))</span> <span style="color: #66d9ef">then  </span>
<span style="color: #66d9ef">       </span><span style="color: #f8f8f2">pnh_i_out</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">pi_i</span> 
     <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  else</span>

<span style="color: #75715e">!==============================================================</span>
<span style="color: #75715e">!  non-hydrostatic EOS</span>
<span style="color: #75715e">!==============================================================</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
     <span style="color: #f8f8f2">p_over_exner(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">Rgas</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta_dp(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">(</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">dphi(:,:,k))</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
     <span style="color: #f8f8f2">pnh(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">p0</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">(p_over_exner(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0)</span><span style="color: #f92672">**</span><span style="color: #f8f8f2">(</span><span style="color: #ae81ff">1</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">(</span><span style="color: #ae81ff">1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">kappa))</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">pnh(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">p0</span> <span style="color: #f92672">*</span> <span style="color: #f8f8f2">bfb_pow(p_over_exner(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0,</span><span style="color: #ae81ff">1</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">(</span><span style="color: #ae81ff">1</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">kappa))</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">exner(:,:,k)</span> <span style="color: #f92672">=</span>  <span style="color: #f8f8f2">pnh(:,:,k)</span><span style="color: #f92672">/</span> <span style="color: #f8f8f2">p_over_exner(:,:,k)</span>
  <span style="color: #f8f8f2">enddo</span>
<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</span>
<span style="color: #75715e">! boundary terms</span>
<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  </span>
   <span style="color: #f8f8f2">pnh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">hvcoord%hyai(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">hvcoord%ps0</span>  <span style="color: #75715e">! hydrostatic ptop    </span>
   <span style="color: #75715e">! surface boundary condition pnh_i determined by w equation to enforce</span>
   <span style="color: #75715e">! w b.c.  This is computed in the RHS calculation.  Here, we use</span>
   <span style="color: #75715e">! an approximation (hydrostatic) so that dpnh/dpi = 1</span>
   <span style="color: #f8f8f2">pnh_i(:,:,nlevp)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">pnh(:,:,nlev)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dp3d(:,:,nlev)</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
   <span style="color: #75715e">! extrapolote NH perturbation:</span>
   <span style="color: #75715e">!pnh_i(:,:,nlevp) = pi_i(:,:,nlevp) + (3*(pnh(:,:,nlev)-pi(:,:,nlev)) - (pnh(:,:,nlev-1)-pi(:,:,nlev-1)) )/2</span>


   <span style="color: #75715e">! compute d(pnh)/d(pi) at interfaces</span>
   <span style="color: #75715e">! use one-sided differences at boundaries</span>
   <span style="color: #f8f8f2">dp3d_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">dp3d(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
   <span style="color: #f8f8f2">dp3d_i(:,:,nlevp)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">dp3d(:,:,nlev)</span>
   <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>
      <span style="color: #f8f8f2">dp3d_i(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">(dp3d(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">dp3d(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
   <span style="color: #66d9ef">end do</span>

<span style="color: #66d9ef">   </span><span style="color: #f8f8f2">dpnh_dp_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>  <span style="color: #f92672">=</span> <span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(pnh(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">pnh_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span>
   <span style="color: #f8f8f2">dpnh_dp_i(:,:,nlevp)</span>  <span style="color: #f92672">=</span> <span style="color: #ae81ff">2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(pnh_i(:,:,nlevp)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">pnh(:,:,nlev))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d_i(:,:,nlevp)</span>
   <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>
      <span style="color: #f8f8f2">dpnh_dp_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(pnh(:,:,k)</span><span style="color: #f92672">-</span><span style="color: #f8f8f2">pnh(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">dp3d_i(:,:,k)</span>        
   <span style="color: #66d9ef">end do</span>
<span style="color: #66d9ef">   </span>

<span style="color: #66d9ef">   if</span> <span style="color: #f8f8f2">(present(pnh_i_out))</span> <span style="color: #66d9ef">then</span>
      <span style="color: #75715e">! boundary values already computed. interpolate interior</span>
      <span style="color: #75715e">! use linear interpolation in hydrostatic pressure coordinate</span>
      <span style="color: #75715e">! if pnh=pi, then pnh_i will recover pi_i</span>
      <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">2</span><span style="color: #f8f8f2">,nlev</span>
         <span style="color: #f8f8f2">pnh_i(:,:,k)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">(dp3d(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">pnh(:,:,k)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">dp3d(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">pnh(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">&amp;</span>
              <span style="color: #f8f8f2">(dp3d(:,:,k</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">dp3d(:,:,k))</span>
      <span style="color: #f8f8f2">enddo</span>
      <span style="color: #f8f8f2">pnh_i_out</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">pnh_i</span>    
   <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">   </span>
<span style="color: #66d9ef">  endif</span> <span style="color: #75715e">! hydrostatic/nonhydrostatic version</span>
  <span style="color: #66d9ef">end subroutine</span> 



  <span style="color: #75715e">!_____________________________________________________________________</span>
  <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">phi_from_eos(hvcoord,phis,vtheta_dp,dp,phi_i)</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! Use Equation of State to compute geopotential</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! input:  dp, phis, vtheta_dp  </span>
<span style="color: #75715e">! output:  phi</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! used to initialize phi for dry and wet test cases</span>
<span style="color: #75715e">! used to compute background phi for reference state</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! NOTE1: dp is pressure layer thickness.  If pnh is used to compute thickness, this</span>
<span style="color: #75715e">! routine should be the discrete inverse of pnh_and_exner_from_eos().</span>
<span style="color: #75715e">! This routine is usually called with hydrostatic layer thickness (dp3d), </span>
<span style="color: #75715e">! in which case it returns a hydrostatic PHI</span>
<span style="color: #75715e">!</span>
<span style="color: #75715e">! NOTE2: Exner pressure is defined in terms of p0=1000mb.  Be sure to use global constant p0,</span>
<span style="color: #75715e">! instead of hvcoord%ps0, which is set by CAM to ~1021mb</span>
<span style="color: #75715e">!  </span>
<span style="color: #75715e">!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!</span>
  <span style="color: #66d9ef">implicit none</span>
<span style="color: #66d9ef">  </span>
<span style="color: #66d9ef">  type</span> <span style="color: #f8f8f2">(hvcoord_t),</span>      <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span>  <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>                      <span style="color: #75715e">! hybrid vertical coordinate struct</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">vtheta_dp(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dp(np,np,nlev)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">phis(np,np)</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind),</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(out)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">phi_i(np,np,nlevp)</span>
 
  <span style="color: #75715e">!   local</span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">p(np,np,nlev)</span> <span style="color: #75715e">! pressure at cell centers </span>
  <span style="color: #66d9ef">real</span> <span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">p_i(np,np,nlevp)</span>  <span style="color: #75715e">! pressure on interfaces</span>

  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">k</span>

<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">NDEBUG</span>
  <span style="color: #66d9ef">logical</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">ierr</span>
  <span style="color: #66d9ef">integer</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">i,j,k2</span>

  <span style="color: #f8f8f2">ierr</span><span style="color: #f92672">=</span> <span style="color: #f8f8f2">any(vtheta_dp(:,:,:)</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span>  <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">&amp;</span>
          <span style="color: #f8f8f2">any(dp(:,:,:)</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span> <span style="color: #f8f8f2">)</span>

  <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(ierr)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">     print</span> <span style="color: #f92672">*</span><span style="color: #f8f8f2">,</span><span style="color: #e6db74">&#39;bad state in phi_from_eos:&#39;</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">j</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">i</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,np</span>
     <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
        <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">(vtheta_dp(i,j,k)</span> <span style="color: #f92672">&lt;</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">(dp(i,j,k)</span><span style="color: #f92672">&lt;</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">           print</span> <span style="color: #f92672">*</span><span style="color: #f8f8f2">,</span><span style="color: #e6db74">&#39;bad i,j,k=&#39;</span><span style="color: #f8f8f2">,i,j,k</span>
           <span style="color: #66d9ef">print</span> <span style="color: #f92672">*</span><span style="color: #f8f8f2">,</span><span style="color: #e6db74">&#39;vertical column: dp,vtheta_dp&#39;</span>
           <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k2</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
              <span style="color: #66d9ef">write</span><span style="color: #f8f8f2">(</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">,</span><span style="color: #e6db74">&#39;(i3,4f14.4)&#39;</span><span style="color: #f8f8f2">)</span> <span style="color: #f8f8f2">k2,dp(i,j,k2),vtheta_dp(i,j,k2)</span>
           <span style="color: #f8f8f2">enddo</span>
           <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">abortmp(</span><span style="color: #e6db74">&#39;EOS bad state: dp or vtheta_dp &lt; 0&#39;</span><span style="color: #f8f8f2">)</span>
        <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">enddo</span>
     <span style="color: #f8f8f2">enddo</span>
     <span style="color: #f8f8f2">enddo</span>
  <span style="color: #66d9ef">endif</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
  <span style="color: #75715e">! compute pressure on interfaces                                                                                   </span>
  <span style="color: #f8f8f2">p_i(:,:,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">hvcoord%hyai(</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">hvcoord%ps0</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
     <span style="color: #f8f8f2">p_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">p_i(:,:,k)</span> <span style="color: #f92672">+</span> <span style="color: #f8f8f2">dp(:,:,k)</span>
  <span style="color: #f8f8f2">enddo</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,nlev</span>
     <span style="color: #f8f8f2">p(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">(p_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">p_i(:,:,k))</span><span style="color: #f92672">/</span><span style="color: #ae81ff">2</span>
  <span style="color: #f8f8f2">enddo</span>
 
  <span style="color: #f8f8f2">phi_i(:,:,nlevp)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">phis(:,:)</span>
  <span style="color: #66d9ef">do </span><span style="color: #f8f8f2">k</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">nlev,</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">,</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifdef</span> <span style="color: #f8f8f2">HOMMEXX_BFB_TESTING</span>
     <span style="color: #f8f8f2">phi_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">phi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">+</span> <span style="color: #f8f8f2">(Rgas</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta_dp(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">bfb_pow(p(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0,(kappa</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">     </span><span style="color: #f8f8f2">phi_i(:,:,k)</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">phi_i(:,:,k</span><span style="color: #f92672">+</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">)</span><span style="color: #f92672">+</span><span style="color: #f8f8f2">(Rgas</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">vtheta_dp(:,:,k)</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">(p(:,:,k)</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0)</span><span style="color: #f92672">**</span><span style="color: #f8f8f2">(kappa</span><span style="color: #f92672">-</span><span style="color: #ae81ff">1</span><span style="color: #f8f8f2">))</span><span style="color: #f92672">/</span><span style="color: #f8f8f2">p0</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">  </span><span style="color: #f8f8f2">enddo</span>
  <span style="color: #66d9ef">end subroutine</span>

<span style="color: #66d9ef">end module</span>
</pre></div>

</pre>.