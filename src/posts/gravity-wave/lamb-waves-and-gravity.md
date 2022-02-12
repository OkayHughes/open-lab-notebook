---
date: 2021-08-30
tags:
  - posts
  - gravity_wave
eleventyNavigation:
  key: Lamb Waves and Gravity
  parent: The two-mountain gravity wave
layout: layouts/post.njk
---



## Lamb wave derivation in height coordinates

Let `$$ f=0 $$` i.e. no rotation and make the hydrostatic approximation to obtain the shallow Primitive Equations. Assume the absence of background horizontal flow. 
The typical linearization gives
\begin{align*}
    \frac{\partial u'}{\partial t} &= -\frac{\partial p'}{\partial x} \\
    \frac{\partial p'}{\partial z} &= -\rho' g \\
\end{align*} 

<table class="eqn">
  <tr>
    <td>$$ \frac{\partial u'}{\partial t}  $$</td> <td> $$= -\frac{\partial p'}{\partial x} $$ </td>
  </tr>
  <tr>
    <td>$$\frac{\partial p'}{\partial z} $$</td> <td> $$ = -\rho' g  $$</td>
  </tr>
</table>


Deriving a single equation for pressure and assuming a wave solution gives:
`$$$ p' = p_0 e^{-\frac{g}{c_s^2}z}e^{i(kx-\nu t)},$$$`

with the vertical wavenumber `$$m=i\frac{g}{c_s^2},$$` with the dispersion relation `$$c = \sqrt{\gamma R_dT}.$$` 

This illustrates your point that if we look at a single pressure level, one still derives purely horizontal acoustic horizontal modes. However, why does a lamb wave decay with increasing height? The extra `$$e^{-\frac{g}{c_s^2}z}$$` term explains why these waves decay with height, and the best way I've found to understand where this comes from can be derived by looking at a shallow water model for one layer of the atmosphere.

## Lamb wave derivation in shallow water system:
Interpret one layer of the atmosphere such that `$$$\Phi \equiv g(z(p_2) - z(p_1)),$$$`
that is, we are looking at a shallow water system where geopotential height measures the thickness between two known pressure levels. Then the linearized shallow water equations without rotation take the form
\begin{align*}
    \frac{\partial u'}{\partial t} &= -\frac{\partial \Phi'}{\partial x}\\
    \frac{\partial v'}{\partial t} &= -\frac{\partial \Phi'}{\partial y} \\
    \frac{\partial \Phi'}{\partial t} &= -\overline{\Phi} \left(\frac{\partial u'}{\partial x} + \frac{\partial v'}{\partial y}\right)
\end{align*}

<table class="eqn">
  <tr>
    <td>$$ \frac{\partial u'}{\partial t} $$</td> <td> $$= -\frac{\partial \Phi'}{\partial x} $$ </td>
  </tr>
  <tr>
    <td>$$ \frac{\partial v'}{\partial t} $$</td> <td> $$ = -\frac{\partial \Phi'}{\partial y} $$</td>
  </tr>
  <tr>
    <td>$$ \frac{\partial \Phi'}{\partial t} $$</td> <td> $$ = -\overline{\Phi} \left(\frac{\partial u'}{\partial x} + \frac{\partial v'}{\partial y}\right) $$</td>
  </tr>
</table>


Note, we assume a temperature profile that is constant in the vertical. The hydrostatic relation gives
`$$$\frac{\partial \Phi}{\partial p} = -\frac{R_d T_0(x, y)}{p}  $$$` 
and integrating gives
`$$$ \Phi(p_2) - \Phi(p_1) &= R_dT(x, y) \ln(p_2/p_1) $$$`
where we emphasize that `$$\ln(p_2/p_1)$$` is a constant. This gives the key fact that makes Lamb waves so counter-intuitive: the hypsometric equation implies that time variation in the height of our shallow water system are proportional to time variation in the horizontal temperature structure. In this case, acoustic waves that induce adiabatic expansion and compression necessarily cause vertical motion, which is resisted by the force of gravity.


In order to make this even more quantitative, we can derive a single equation for height by rearranging the above linear PDE and substitute to find

<table class="eqn">
  <tr>
    <td>$$\frac{\partial \Phi'}{\partial t^2}$$</td> <td>$$= \overline{\Phi}\nabla^2\Phi'$$</td>
  </tr>
  <tr>
    <td></td><td>$$= \overline{\Phi}\ln(p_2/p_1)R_d\nabla^2 T'(x, y) $$</td>
  </tr>
</table>


This repeats the dispersion relation that gives us that horizontal propagation occurs at $c_s = \sqrt{\gamma R_d T}.$ Note that in the case that the atmosphere is not isothermal in the vertical, there are slight variations of the horizontal speed with which the lamb wave propagates.

\subsection*{Summary}
The assumption of hydrostatic balance necessarily couples thermodynamic processes with vertical motion. Because Lamb waves/external modes propagate horizontally through adiabatic expansion and contraction, this is necessarily opposed by the force of gravity. At a certain pressure level, the air above this layer resists this expansion and acts as a restoring force. 

To put it slightly differently, a lamb wave's vertical pressure profile is uniquely determined the moment you initialize its signature in the surface pressure field. The $u, v,$ and $T$ fields necessary to ensure that this wave propagates can then be derived. This derivation is tightly related to the strength of gravity, because it necessarily makes use of the hydrostatic relation.












\end{document}
