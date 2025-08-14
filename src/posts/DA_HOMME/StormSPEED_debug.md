---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Why is StormSPEED output garbage?
layout: layouts/post.njk
---

Stormspeed output appears to be garbage. Note: the problem is PG specific! 
It is present both in interpolated and native output.
In aquaplanet simulations, the edges of the polar panels are clearly present in the output. Inconclusive on whether side panel edges are imprinting in a less visible way. 

*Unifying question: is this problem due to use of explicit new code included in StormSPEED, or due to an interface inconsistency when passing CAM quantities through to HOMME routines?*
## Promising avenues of exploration:
* Examine divergence, gradient, vorticity calculation for test flow field trojan-horsed in via 2016 BW initialization
* Prep scatter plot plotting for diagnostics, especially for `ncol_d`


## Notes
Working case is `/glade/derecho/scratch/owhughes/StormSPEED_NCAR.ne30pg3_ne30pg3_mg17.QPC7.AQP.is_aqp_garbo/run`


### Working notes 08/05
Item number 1: is there a problem?
* Output GLL quantities
* GLL output + NP4 simulations confirm that the problem is with PG2GLL/GLL2PG


Next steps:
* HS test case. Output every time step. Stop after 10 steps. Add constant U/V forcing, See if garbage.
* Reduce U amplitude


Findings:
* Zeroed out all forcings in HS except `$$\Delta U = C\cos(\phi)$$`. Initialized with US standard atmosphere
* Element columns (but not rows) are visible in GLL output when source of signal is on PG.
* Indexing error?
* Indexing error also shows up in T!! Note: T forcing is constant everywhere, meaning that this is an indexing error on the metdet/Dinv side of things


### Notes 08/06

* Output happens in `physics/cam/cam_diagnostics.F90`
* Focus on debugging T to focus on this


* Breadcrumb 1: where is "state%u(:ncol,:)" set?


* Relevant function calls: `dynamics/senh/dp_coupling.F90`
* Line 140: `gfr_dyn_to_fv_phys`
* Line 320: `gfr_fv_phys_to_dyn` is probably the problem.

Hypothesis: `gllfvremap_mod` contains the calls that contain the issue.
Idea: trojan horse info into the T field.
* Problem appears on boundaries and interior pts of element, so it's likely not DSS issue
* Testing if `gfr_dyn_to_fv_phys_hybrid` works
    * We know this is being called, as calling abort near the T remap crashes the run
    * Does overwriting `FT` with uniform value of 1 show up in output?


* Setting FT with uniform value still shows grid imprinting (but does change measured value after 1 time step).
* Does disabling PD coupling entirely solve the problem?

* In theta, update to T is performed via dt*elem(ie)%derived%FVTheta(:,:,:) 


* Returning to FADIAB vector output: 
* presumptive error is line 550 in `interp_mod.F90`

* Note: we're not touching `interp_mod`. Issue is in `gfr_fv_phys_to_dyn`

* Debugging:
    * overriding uv values in `gfr_fv_phys_to_dyn` with constant value successfully propagates to output.
    * Hypothesis: uv indexing is screwed up. 


* Wildcard: set metdet to 1 + cos(lat), temperature should show issues?


* When using scalar routine to remap v, pattern looks correct. Error is specific to `gfr_g2f_vector`.
* `gfr%D_f` almost certainly source of problem!
* Disabling both map to contravariant coords on GLL points and contra->physical on fv points 
results in reasonable looking U, V.
* Outputting contravariant coords shows element boundaries, as one would expect.
* `gfr%D_f` lines are exactly the same in stock E3SM HOMME
* Is `grf%D_f` just transposed? When transposed, both U and V are screwy.
* Lower row is wrong. Transposing `$$D_{2, 1}$$` `$$D_{2, 2}$$` does not fix the problem.


* Question: is `gfr%fv_metdet` correct? If `gfr%D_f` is transposed, this would result in identical `gfr%fv_metdet`

#### Where is `gfr%D_f` set?
* set in `gfr_init_Dmap`

What is going on in these lines?
```
             k = i + (j-1)*nf
             wrk = wrk*sqrt(gfr%fv_metdet(k,ie)/abs(det))
             det = gfr%fv_metdet(k,ie)

             gfr%D_f(k,:,:,ie) = wrk

             gfr%Dinv_f(k,1,1,ie) =  wrk(2,2)/det
             gfr%Dinv_f(k,1,2,ie) = -wrk(1,2)/det
             gfr%Dinv_f(k,2,1,ie) = -wrk(2,1)/det
             gfr%Dinv_f(k,2,2,ie) =  wrk(1,1)/det
```

* Using cubed sphere map type 0.
* We've confirmed that this subroutine is being called.
* Overwriting `D_f` lower row with 0 zeros out V. This is correct. 

* Idea: check if cartp points behave as I would expect them to.

* Observed problem is consistent with `b` local coordinate being incorrect on equatorial cube faces.
This is because `$$$ D = \begin{pmatrix} \cos(\phi) & 0 \\ 0 & 1 \end{pmatrix} \frac{\partial (\lambda, \phi)}{\partial (a, b)}$$$` has derivatives with respect to `b` in the lower row.


* How is `corners` calculated?



Hypothesis: are we just seeing lack of commutativity between the remapping operator and transformation to contravariant coordinates? That is, `gfr_g2f_remap` performs the following:
`$$$\boldsymbol{u}_f = D^{-1}(\boldsymbol{x}_f) \left[ \textrm{GllToFv}\left(D(\boldsymbol{x}_g) \boldsymbol{u}(\boldsymbol{x}_g)  \right) \right]$$$` 
