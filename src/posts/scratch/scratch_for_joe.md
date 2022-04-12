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

Suppose we have a prescribed function `$$ \rho_i(r, z, t) $$` with units of `$$ \frac{\mathrm{kg}}{\mathrm{m}^3} $$` and for the purposes
of physics update I will assume we are looking at a single point and thus we only care about
`$$ \rho_i(r_0, z_0, t) \equiv \rho_i(t) $$`

In fact with in CAM we only have control over `$$ c = \frac{\rho_i(t)}{\rho_{\textrm{air}}(t)} $$`

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


Here's the assumption that lets us 

