---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Adding PV and PT as dynamical tracers to E3SM
  parent: E3SM
layout: layouts/post.njk
---

# Idea: look at how moisture species are handled within HOMME?

in `src/theta-l/share/prim_advection_mod.f90` we find

<pre>
<!-- HTML generated using hilite.me --><div style="background: #272822; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%">  <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">Prim_Advec_Init1(par,</span> <span style="color: #f8f8f2">elem)</span>
    <span style="color: #66d9ef">type</span><span style="color: #f8f8f2">(parallel_t)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">par</span> 
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(element_t)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">elem(:)</span>

    <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">prim_advec_init1_rk2(par,</span> <span style="color: #f8f8f2">elem)</span>
    <span style="color: #66d9ef">call </span><span style="color: #f8f8f2">sl_init1(par,elem)</span>

  <span style="color: #66d9ef">end subroutine </span><span style="color: #f8f8f2">Prim_Advec_Init1</span>

  <span style="color: #66d9ef">subroutine </span><span style="color: #f8f8f2">Prim_Advec_Tracers_remap(</span> <span style="color: #f8f8f2">elem</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">deriv</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">hvcoord</span> <span style="color: #f8f8f2">,</span>  <span style="color: #f8f8f2">hybrid</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">dt</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">tl</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">nets</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">nete</span> <span style="color: #f8f8f2">)</span>
    <span style="color: #66d9ef">implicit none</span>
<span style="color: #66d9ef">    type</span> <span style="color: #f8f8f2">(element_t)</span>     <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">elem(:)</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(derivative_t)</span>  <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in</span>   <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">deriv</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hvcoord_t)</span>     <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in</span>   <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hvcoord</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(hybrid_t)</span>      <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in</span>   <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">hybrid</span>
    <span style="color: #66d9ef">real</span><span style="color: #f8f8f2">(kind</span><span style="color: #f92672">=</span><span style="color: #f8f8f2">real_kind)</span> <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in</span>   <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">dt</span>
    <span style="color: #66d9ef">type</span> <span style="color: #f8f8f2">(TimeLevel_t)</span>   <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(inout)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">tl</span>
    <span style="color: #66d9ef">integer</span>              <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in</span>   <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">nets</span>
    <span style="color: #66d9ef">integer</span>              <span style="color: #f8f8f2">,</span> <span style="color: #66d9ef">intent</span><span style="color: #f8f8f2">(in</span>   <span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">::</span> <span style="color: #f8f8f2">nete</span>

    <span style="color: #66d9ef">if</span> <span style="color: #f8f8f2">(transport_alg</span> <span style="color: #f92672">==</span> <span style="color: #ae81ff">0</span><span style="color: #f8f8f2">)</span> <span style="color: #66d9ef">then</span>
<span style="color: #66d9ef">       call </span><span style="color: #f8f8f2">Prim_Advec_Tracers_remap_rk2(</span> <span style="color: #f8f8f2">elem</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">deriv</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">hvcoord</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">hybrid</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">dt</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">tl</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">nets</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">nete</span> <span style="color: #f8f8f2">)</span>
    <span style="color: #66d9ef">else</span>
<span style="color: #66d9ef">       call </span><span style="color: #f8f8f2">Prim_Advec_Tracers_remap_ALE(</span> <span style="color: #f8f8f2">elem</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">deriv</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">hvcoord</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">hybrid</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">dt</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">tl</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">nets</span> <span style="color: #f8f8f2">,</span> <span style="color: #f8f8f2">nete</span> <span style="color: #f8f8f2">)</span>
    <span style="color: #66d9ef">end if</span>
<span style="color: #66d9ef">  end subroutine </span><span style="color: #f8f8f2">Prim_Advec_Tracers_remap</span>
</pre></div>
</pre>

Figure out where the tracer length of `Q` is set!


