---
date: 2021-08-31
tags:
  - posts
  - directory
eleventyNavigation:
  key: Scratch for Joe vis a vis tracer concentration
  parent: scratch
layout: layouts/post.njk
---

Suppose we have a prescribed function `$$ \rho_m(r, z, t) $$` with units of `$$ \frac{\mathrm{kg}}{\mathrm{m}^3} $$` and for the purposes
of physics update I will assume we are looking at a single point and thus we only care about
`$$ \rho_m(r_0, z_0, t) \equiv \rho_m(t) $$`

In fact with in CAM we only have control over `$$ c = \frac{\rho_m(t)}{\rho_{\textrm{air}}(t)} $$`

From the following code snippet 

<details>
<summary><code>src/physics/cam/physics_types.F90</code></summary>
  
  
```
  ! Update constituents, all schemes use time split q: no tendency kept
    call cnst_get_ind('CLDICE', ixcldice, abort=.false.)
    call cnst_get_ind('CLDLIQ', ixcldliq, abort=.false.)
    ! Check for number concentration of cloud liquid and cloud ice (if not present
    ! the indices will be set to -1)
    call cnst_get_ind('NUMICE', ixnumice, abort=.false.)
    call cnst_get_ind('NUMLIQ', ixnumliq, abort=.false.)
    call cnst_get_ind('NUMRAI', ixnumrain, abort=.false.)
    call cnst_get_ind('NUMSNO', ixnumsnow, abort=.false.)

    do m = 1, pcnst
       if(ptend%lq(m)) then 
          do k = ptend%top_level, ptend%bot_level
             state%q(:ncol,k,m) = state%q(:ncol,k,m) + ptend%q(:ncol,k,m) * dt 
          end do

          ! now test for mixing ratios which are too small
          ! don't call qneg3 for number concentration variables
          if (m /= ixnumice  .and.  m /= ixnumliq .and. &
              m /= ixnumrain .and.  m /= ixnumsnow ) then 
             call qneg3(trim(ptend%name), state%lchnk, ncol, state%psetcols, pver, m, m, qmin(m:m), state%q(:,1:pver,m:m))
          else 
             do k = ptend%top_level, ptend%bot_level
                ! checks for number concentration
                state%q(:ncol,k,m) = max(1.e-12_r8,state%q(:ncol,k,m))
                state%q(:ncol,k,m) = min(1.e10_r8,state%q(:ncol,k,m))
             end do
          end if

       end if

    end do

    !------------------------------------------------------------------------
    ! This is a temporary fix for the large H, H2 in WACCM-X
    ! Well, it was supposed to be temporary, but it has been here
    ! for a while now.
    !------------------------------------------------------------------------
    if ( waccmx_is('ionosphere') .or. waccmx_is('neutral') ) then 
       call cnst_get_ind('H', ixh) 
       do k = ptend%top_level, ptend%bot_level
          state%q(:ncol,k,ixh) = min(state%q(:ncol,k,ixh), 0.01_r8)
       end do

       call cnst_get_ind('H2', ixh2)
       do k = ptend%top_level, ptend%bot_level
          state%q(:ncol,k,ixh2) = min(state%q(:ncol,k,ixh2), 6.e-5_r8)
       end do
    endif
```
  
</details>


we find that although we theoretically believe that we can set the
tracer tendency `$$(\partial_t \, c)(t_0)$$`, the physics update is 
actually a first order explicit scheme, and so we have control over 
`$$\Delta c, $$` where `$$ c(t_0 + \Delta t) = c(t_0) + \frac{\Delta c}{\Delta t} \Delta t.$$`
Note that we know the timestep `$$\Delta t $$` so we can cancel it automatically.

Note that the `$$\Delta t $$` given here is the `$$ \Delta t_{\textrm{phys}} $$` using the notation
of [this presentation](https://www.cesm.ucar.edu/events/tutorials/2018/files/Lecture2-lauritzen.pdf)

I only really understand the time substepping scheme for SE, but as far as I can tell the of
the three options laid out in [this article](https://www.osti.gov/servlets/purl/1706688)
tracer quantity will be added to the state in its entirety at the physics time step
unless you force it to do "dribbling" which would be a wild choice
for a non-thermodynamic tracer. 

If the addition is happening all at once at the time of the physics update, then for
the purposes of conservation all we care about is that _we add a total amount of tracer mass to
the grid point at this sudden update_.

To make this fully concrete, suppose we take our state before the physics update is called:
`$$\{T, U, V, P, c_m\}_{\textrm{before physics}}$$`. This state represents
the diagnostic state of the atmosphere at the current time step _after the previous dynamics
and physics are finished_. 
If what we care about is the total mass added to the atmosphere over the injection period,
then all we are about is that _from the time of the last physics update to this physics update_
we have added `$$\Delta \rho_m$$` of this tracer to the atmosphere. 

As such, the discrete equation we need to satisfy is
given `$$\{T, U, V, P, c_m\}_{\textrm{before physics}}$$` we want that 

`$$$ \rho_m(t_{i, \textrm{after injection}}) - \rho_m(t_{i, \textrm{before injection}}) =  \int_{t_{i-1}}^{t_{i}} \frac{\mathrm{d}}{\mathrm{d}t}\left[\rho_{m, \textrm{analytic}}(t)\right] \, \mathrm{d}t$$$`

where the sudden injection that is happening at `$$t + \Delta t_\mathrm{\mathrm{phys}}$$` is compensating for 
the injection over the last time step neglecting dynamics.

As such, we can calculate 
`$$$ \rho_m(t_{i, \textrm{after injection}}) = \rho_{\mathrm{air}}(t_i) \cdot c_m(t_{i, \textrm{after injection}}) $$$`

and 
`$$$ \rho_m(t_{i, \textrm{before injection}}) = \rho_{\mathrm{air}}(t_i) \cdot c_m(t_{i, \textrm{before injection}}) $$$`

And we can rearrange to find

`$$$ \rho_{\mathrm{air}}(t_i) \cdot c_m(t_{i, \textrm{after injection}}) - \rho_{\mathrm{air}}(t_i) \cdot c_m(t_{i, \textrm{before injection}}) = \Delta \rho_{m, \textrm{analytic}}$$$`
`$$$ \rho_{\mathrm{air}}(t_i) \cdot \left(c_m(t_{i, \textrm{before injection}}) + \Delta t \frac{\Delta c_m}{\Delta t}\right)  - \rho_{\mathrm{air}}(t_i) \cdot c_m(t_{i, \textrm{before injection}}) = \Delta \rho_{m, \textrm{analytic}}$$$`
`$$$   \Delta c_m  = \frac{\Delta \rho_{m, \textrm{analytic}}}{\rho_{\mathrm{air}}(t_i)}$$$`



The long and short of it is, this will precisely control the amount of mass added but will not spread tracer insertion
over tracer advection timesteps. If you really want to have both, set the dynamics and the physics time step
to be the same. In the HSW idealized setup the added time will be negligible.

To sum up the single trick that I used, because the code can be made to instantaneously update
the tracer by a quantity before dynamics or tracer advection starts up again,
we get to make a principled assumption that `$$ \rho_{\mathrm{air}} $$` is constant
during our update step, which is actually what the code is doing.

The reason I'm using the `$$\{T, U, V, P, c_m\}_{\textrm{before physics}}$$` state is that sometimes
these quantities are dribbled over the previous dynamics substepping. By doing the update right when the
physics step begins, your update will be consistent with the diagnosed density at the beginning of the physics timestep.



<!-- As such the main issue that we face is that `$$ \rho_{\mathrm{air}}$$` may be time varying,
which makes calculation of `$$ c = \frac{\rho_i}{\rho_{\mathrm{air}}}.$$`

However, we are using a first-order scheme. The continuous identity that
we want our discretized system to satisfy is 

`$$$ \rho_{\mathrm{air}}(t_{i+1}) c_i(t_{i+1}) - \rho_{\mathrm{air}}(t_{i}) c_i(t_{i}) = \rho_i(t_{i+1}) - \rho_i(t_i)$$$`
where `$$t_{i+1} = t_i + \Delta t_{\mathrm{phys}} $$`

We know the righthand side analytically. 
At a given physics update we know `$$\rho_i(t)$$`, `$$\rho_{\mathrm{air}}(t_i).$$`

If we add a variable to the physics routine we can keep track of `$$\rho_{i-1} $$` which would make the lefthand

 -->
