---
date: 2021-08-30
tags:
  - posts
  - gravity_wave
eleventyNavigation:
  key: Deriving a minimal model of the topography-induced lamb wave
  parent: The two-mountain gravity wave
layout: layouts/post.njk
---



First I'm trying to derive a steady state with extremely benign properties (i.e. use the usual base state
but set `$$ T_0 = T_E = T_P = 270 \mathrm{K} $$`.)

In `ic_baroclinic.F90` set `T0E = T0P = 270.0_r8`, and set `moistq0 = 1.0e-12_r8` (not changing the moisture coefficient
caused mild grid-scale static instability in the horse (?) latitudes).
Put it in an oven preheated to around 36 PE for 5 minutes (translation: run the case with PE=36).


This seems to result in an extremely benign atmosphere with no flow at all

### Adding topography back in

Set `mountain_height=2000.0_r8` in `ic_baroclinic.F90`.

Model runs.

Topography creates a gravity wave that shows up as a signature in `$$ \omega_{850} $$` which shows up if you set
the plotting range to `[-0.02, 0.02]`.

### Tailor topography to trigger an equatorial wave of this form:

Increase `$$ \phi_{\mathrm{scale}} = 6^\circ $$`, `$$ \lambda_{\mathrm{scale}} = 6^\circ $$`, increase
the latitudinal and longitudinal powers to 6. I'll leave the mountain height at 2000m for the moment. We move 
`$$ \phi_{\mathrm{center}} = 0^\circ $$` and remove one of the mountains.

At frame 10 (hourly output), wave signature has approximate magnitude of 0.02 Pa/s
Increasing divergence damping doesn't change the maximum of this wave. With this in mind, 
I'm going to analyze the speed of this wave using my scripts, then try running the same wave at different
temperatures.

<img class="center medium" src="https://open-lab-notebook-assets.glitch.me/assets/lamb_wave/minimal_model/speed_comparison.png">

This demonstrates that propagation speed appears to increase continuously with baseline temperature.

### Quantitative calculation of `$$ c $$` as `$$ T $$` increases:
I used ne60 runs at `$$ T = \{270\mathrm{K}, 315\mathrm{K}, 360\mathrm{K}, 450\mathrm{K}\} $$`.
I calculated the wave speeds based on the simplified equation derived in the original lamb wave post
based on the temperature using `$$ \overline{T} =  \langle T_{850} \rangle_h. $$`. I calculated the speed by
measuring great circle distance traveled in 6 hours starting from 01:00:00 on day 1 (looking at 1 hour measurements shows that 
the speed is approximately constant, but these are more noisy). I measured the wave traveling east of the orography.
Tomorrow I will repeat several of these runs with a properly isothermal atmosphere in order to see if it changes the results in the
following table

<table class="eqn">
  <tr>
    <th></th>
  <th>
    $$T_{\mathrm{surface}}=270\mathrm{K}$$ ,
  </th>
  <th>
    $$T_{\mathrm{surface}}=315\mathrm{K}$$ ,
  </th>
  <th>
    $$T_{\mathrm{surface}}=360\mathrm{K}$$ 
  </th>
  <th>
    $$T_{\mathrm{surface}}=450\mathrm{K}$$ 
  </th>
  </tr>
  <tr>
    <td> $$c_{\mathrm{predicted}, 850\mathrm{hPa}} $$</td> <td>325.8 </td> <td>352.0</td>  <td>376.3 </td> <td>420.7</td>
  </tr>
  <tr>
    <td> $$c_{\mathrm{measured}, 850\mathrm{hPa}}  $$</td> <td>303.9 </td> <td> 323.95 </td> <td> 345.67 </td> <td> 385.49 </td>
  </tr>
</table>

The `$$ \Delta c $$` agrees very well between the predicted and measured speeds when `$$T $$` is increased,
however there still seems to be a constant offset. Possibly this is due to the presence of diffusion in 
the model, or it is due to the fact that the atmosphere is not isothermal like the one in
which we derived our very simple formula for the lamb wave.

### Creating an FV model run for comparison:

In the FV model there is _no signature what so ever_ at day 10! If you set the colorbar range
to `[-0.005, 0.005]` at hour 2, you can see the signature of this wave propagating and decaying 
exponentially(?).

