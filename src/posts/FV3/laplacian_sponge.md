---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Creating a laplacian sponge layer mechanism
  parent: FV3 Dycore Posts
layout: layouts/post.njk
---

## Initial plan:
* Track down where rayleigh friction code is.
* Track down where second-order operators are computed.


## Understanding the rayleigh friction code:

<details><summary>Snippet where rayleigh friction is called in <code>atmos_cubed_sphere/model/fv_dynamics.F90</code></summary>

<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">      <span style="color: #66d9ef">if</span><span style="color: #f8f8f2">(</span> <span style="color: #f92672">.not.</span><span style="color: #f8f8f2">flagstruct%RF_fast</span> <span style="color: #f92672">.and.</span> <span style="color: #f8f8f2">flagstruct%tau</span> <span style="color: #f92672">&gt;</span> <span style="color: #ae81ff">0.</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then </span>
<span style="color: #66d9ef">        if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">gridstruct%grid_type</span><span style="color: #f92672">&lt;</span><span style="color: #ae81ff">4</span> <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">gridstruct%bounded_domain</span> <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">is_ideal_case</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> 
<span style="color: #75715e">!         if ( flagstruct%RF_fast ) then</span>
<span style="color: #75715e">!            call Ray_fast(abs(dt), npx, npy, npz, pfull, flagstruct%tau, u, v, w,  &amp;</span>
<span style="color: #75715e">!                          dp_ref, ptop, hydrostatic, flagstruct%rf_cutoff, bd)</span>
<span style="color: #75715e">!         else</span>
             <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">Rayleigh_Super(abs(bdt),</span> <span style="color: #f8f8f2">npx,</span> <span style="color: #f8f8f2">npy,</span> <span style="color: #f8f8f2">npz,</span> <span style="color: #f8f8f2">ks,</span> <span style="color: #f8f8f2">pfull,</span> <span style="color: #f8f8f2">phis,</span> <span style="color: #f8f8f2">flagstruct%tau,</span> <span style="color: #f8f8f2">u,</span> <span style="color: #f8f8f2">v,</span> <span style="color: #f8f8f2">w,</span> <span style="color: #f8f8f2">pt,</span>  <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f8f8f2">ua,</span> <span style="color: #f8f8f2">va,</span> <span style="color: #f8f8f2">delz,</span> <span style="color: #f8f8f2">gridstruct%agrid,</span> <span style="color: #f8f8f2">cp_air,</span> <span style="color: #f8f8f2">rdgas,</span> <span style="color: #f8f8f2">ptop,</span> <span style="color: #f8f8f2">hydrostatic,</span>    <span style="color: #f8f8f2">&amp;</span>    
                 <span style="color: #f92672">.not.</span> <span style="color: #f8f8f2">(gridstruct%bounded_domain</span> <span style="color: #f92672">.or.</span> <span style="color: #f8f8f2">is_ideal_case),</span> <span style="color: #f8f8f2">flagstruct%rf_cutoff,</span> <span style="color: #f8f8f2">gridstruct,</span> <span style="color: #f8f8f2">domain,</span> <span style="color: #f8f8f2">bd)</span>
<span style="color: #75715e">!         endif</span>
        <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">             call </span><span style="color: #f8f8f2">Rayleigh_Friction(abs(bdt),</span> <span style="color: #f8f8f2">npx,</span> <span style="color: #f8f8f2">npy,</span> <span style="color: #f8f8f2">npz,</span> <span style="color: #f8f8f2">ks,</span> <span style="color: #f8f8f2">pfull,</span> <span style="color: #f8f8f2">flagstruct%tau,</span> <span style="color: #f8f8f2">u,</span> <span style="color: #f8f8f2">v,</span> <span style="color: #f8f8f2">w,</span> <span style="color: #f8f8f2">pt,</span>  <span style="color: #f8f8f2">&amp;</span>
                  <span style="color: #f8f8f2">ua,</span> <span style="color: #f8f8f2">va,</span> <span style="color: #f8f8f2">delz,</span> <span style="color: #f8f8f2">cp_air,</span> <span style="color: #f8f8f2">rdgas,</span> <span style="color: #f8f8f2">ptop,</span> <span style="color: #f8f8f2">hydrostatic,</span> <span style="color: #f8f8f2">.true.,</span> <span style="color: #f8f8f2">flagstruct%rf_cutoff,</span> <span style="color: #f8f8f2">gridstruct,</span> <span style="color: #f8f8f2">domain,</span> <span style="color: #f8f8f2">bd)</span>
        <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">      endif</span>
</pre></div>
</pre>

</details>

<details>
<summary>Snippet where Rayleigh friction is called if using Ray_fast in <code>atmos_cubed_sphere/model/dyn_core.F90</code></summary>
  
<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #75715e">! *** Inline Rayleigh friction here?</span>
   <span style="color: #66d9ef">if</span><span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">flagstruct%RF_fast</span> <span style="color: #f92672">.and.</span> <span style="color: #f8f8f2">flagstruct%tau</span> <span style="color: #f92672">&gt;</span> <span style="color: #ae81ff">0.</span> <span style="color: #f8f8f2">)</span>  <span style="color: #f8f8f2">&amp;</span> 
   <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">Ray_fast(abs(dt),</span> <span style="color: #f8f8f2">npx,</span> <span style="color: #f8f8f2">npy,</span> <span style="color: #f8f8f2">npz,</span> <span style="color: #f8f8f2">pfull,</span> <span style="color: #f8f8f2">flagstruct%tau,</span> <span style="color: #f8f8f2">u,</span> <span style="color: #f8f8f2">v,</span> <span style="color: #f8f8f2">w,</span>  <span style="color: #f8f8f2">&amp;</span>
                      <span style="color: #f8f8f2">ks,</span> <span style="color: #f8f8f2">dp_ref,</span> <span style="color: #f8f8f2">ptop,</span> <span style="color: #f8f8f2">hydrostatic,</span> <span style="color: #f8f8f2">flagstruct%rf_cutoff,</span> <span style="color: #f8f8f2">bd)</span>
</pre></div>
</pre>
</details>

## Understanding the second-order diffusion operators in FV3
The model I'll be using is divergence damping. Function calls can be found around line 700 of `atmos_cubed_sphere/model/dyn_core.F90`.

<details>
<summary>
Evidence that $$\nabla^2$$ sponge layer damping is already implemented?
</summary>
  
<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">  <span style="color: #75715e">! Sponge layers with del-2 damping on divergence, vorticity, w, z, and air mass (delp).</span>
<span style="color: #75715e">! no special damping of potential temperature in sponge layers</span>
              <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">k</span><span style="color: #f92672">==</span><span style="color: #ae81ff">1</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> 
<span style="color: #75715e">! Divergence damping:</span>
                 <span style="color: #f8f8f2">nord_k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span>
                 <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(is_ideal_case)</span> <span style="color: #66d9ef">then </span>
<span style="color: #66d9ef">                    </span><span style="color: #f8f8f2">d2_divg</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">max(flagstruct%d2_bg,</span> <span style="color: #f8f8f2">flagstruct%d2_bg_k1)</span>
                 <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">                    </span><span style="color: #f8f8f2">d2_divg</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">max(</span><span style="color: #ae81ff">0.01</span><span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">flagstruct%d2_bg,</span> <span style="color: #f8f8f2">flagstruct%d2_bg_k1)</span>
                 <span style="color: #66d9ef">endif</span>
<span style="color: #75715e">! Vertical velocity:</span>
                   <span style="color: #f8f8f2">nord_w</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span> <span style="color: #f8f8f2">damp_w</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">d2_divg</span>
                   <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">flagstruct%do_vort_damp</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span> 
<span style="color: #75715e">! damping on delp and vorticity:</span>
                        <span style="color: #f8f8f2">nord_v(k)</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">HIWPP</span>
                        <span style="color: #f8f8f2">damp_vt(k)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">d2_divg</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">                   endif</span>
<span style="color: #66d9ef">                   </span><span style="color: #f8f8f2">d_con_k</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.</span> 
              <span style="color: #f8f8f2">elseif</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">k</span><span style="color: #f92672">==</span><span style="color: #ae81ff">2</span> <span style="color: #f92672">.and.</span> <span style="color: #f8f8f2">flagstruct%d2_bg_k2</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0.01</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then </span>
<span style="color: #66d9ef">                   </span><span style="color: #f8f8f2">nord_k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span> <span style="color: #f8f8f2">d2_divg</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">max(flagstruct%d2_bg,</span> <span style="color: #f8f8f2">flagstruct%d2_bg_k2)</span>
                   <span style="color: #f8f8f2">nord_w</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span> <span style="color: #f8f8f2">damp_w</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">d2_divg</span>
                   <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">flagstruct%do_vort_damp</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then </span>
<span style="color: #66d9ef">                        </span><span style="color: #f8f8f2">nord_v(k)</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #f8f8f2">ifndef</span> <span style="color: #f8f8f2">HIWPP</span>
                        <span style="color: #f8f8f2">damp_vt(k)</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.5</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">d2_divg</span>
<span style="color: #960050; background-color: #1e0010">#</span><span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">                   endif</span>
<span style="color: #66d9ef">                   </span><span style="color: #f8f8f2">d_con_k</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.</span> 
              <span style="color: #f8f8f2">elseif</span> <span style="color: #f8f8f2">(</span> <span style="color: #f8f8f2">k</span><span style="color: #f92672">==</span><span style="color: #ae81ff">3</span> <span style="color: #f92672">.and.</span> <span style="color: #f8f8f2">flagstruct%d2_bg_k2</span><span style="color: #f92672">&gt;</span><span style="color: #ae81ff">0.05</span> <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then </span>
<span style="color: #66d9ef">                   </span><span style="color: #f8f8f2">nord_k</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span>  <span style="color: #f8f8f2">d2_divg</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">max(flagstruct%d2_bg,</span> <span style="color: #ae81ff">0.2</span><span style="color: #f92672">*</span><span style="color: #f8f8f2">flagstruct%d2_bg_k2)</span>
                   <span style="color: #f8f8f2">nord_w</span><span style="color: #f92672">=</span><span style="color: #ae81ff">0</span><span style="color: #f8f8f2">;</span>  <span style="color: #f8f8f2">damp_w</span> <span style="color: #f92672">=</span> <span style="color: #f8f8f2">d2_divg</span>
                   <span style="color: #f8f8f2">d_con_k</span> <span style="color: #f92672">=</span> <span style="color: #ae81ff">0.</span> 
              <span style="color: #66d9ef">endif</span>
<span style="color: #66d9ef">       endif</span>
</pre></div>

</pre>
</details>

It appears that horizontal second-order operators are handled within the call to the explicit `d_sw` shallow water subroutine. Therefore there are flags so that the damping coefficients are set to appropriate values in the sponge levels.

## designing an ideal test case to ensure that this implementation is behaving reasonably.

Use the hydrostatic staniforth white test case? Bring that over, at least.

Use the files I modified for the class in the following way:


## Note from 08/06/22
Now that I've looked in the source code in JT's new FV3 dycore branch, it appears that he's already
added namelist variables that enable `$$ \nabla^2 $$` sponge-layer diffusion in the top two layers.
The default namelist configuration disables the conversion of dissipated energy from Rayleigh friction to thermal energy,
This is controlled by the namelist variable `fv3_d_con`.

My task now is to benchmark the performance of these two diffusion methods .



## Comparing Rayleigh friction when `fv3_d_con = 1`


