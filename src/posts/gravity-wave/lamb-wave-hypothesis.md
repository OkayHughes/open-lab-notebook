---
date: 2021-08-30
tags:
  - posts
  - gravity_wave
eleventyNavigation:
  key: Testing the hypothesis that it's a lamb wave
  parent: The two-mountain gravity wave
layout: layouts/post.njk
---


## The mathematics of lamb waves
In the atmosphere there is a special kind of acoustic wave called a Lamb wave, which is a horizontally propagating sound wave 
with no vertical velocity propagation (`$$w'$$` = 0). They are supported by a hydrostatic equation set. It has been observed that the amplitudes of the oscillations of a Lamb wave vary with height.

Use the equations: 
`$$$ \left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right)u'  + \frac{1}{\overline{\rho}} \frac{\partial p'}{\partial x} = 0 $$$`
`$$$ \left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right)p'  + \gamma \overline{p} \frac{\partial u'}{\partial x}  = 0 $$$`

`$$$\frac{\partial p'}{\partial z} = -\rho' g $$$`
`$$$\left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right) \rho' + \overline{\rho} \frac{\partial u'}{\partial x} = 0 $$$` 


Where `$$\overline{p}(z)$$`,  `$$\overline{\rho}(z)$$` depend on height, `$$\overline{u}(z, \phi)$$` , `$$\overline{T}(z, \phi)$$` are taken as parameters and `$$\gamma \equiv c_p/c_v$$`
and eliminate `$$\rho'$$` in the last equation:

`$$$-\frac{1}{g}\left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right) \frac{\partial p'}{\partial z} + \overline{\rho} \frac{\partial u'}{\partial x} = 0 $$$`

We multiply through by `$$-g$$` to get 


`$$$ \left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right) \frac{\partial p'}{\partial z} -g \overline{\rho} \frac{\partial u'}{\partial x} = 0 $$$`

Before we go further that if `$$\rho = \overline{\rho} + \rho'$$` and `$$ p = \overline{p} + p',$$` then we find that `$$\frac{\partial p}{\partial z} = - \rho g$$` which gives us `$$\frac{\partial p'}{\partial z} + \frac{\partial \overline{p}}{\partial z} = - g \left(\overline{\rho} + \rho' \right)$$` and using what we know 
about `$$\rho'$$` and `$$p'$$` we get that `$$\frac{\partial\overline{p}}{\partial z} = -g\overline{\rho}$$` which should be true just from physical intuition. We note that `$$\gamma \neq 0$$` and `$$\overline{p} \neq 0$$` and thus

`$$$ \overline{p} \gamma \left(\frac{\partial}\partial {t} + \overline{u} \frac{\partial}{\partial x} \right) \frac{\partial p'}{\partial z} - g \gamma \overline{p} \overline{\rho}  \frac{\partial u'}{\partial x} = 0 $$$`
`$$$ g \overline{\rho} \left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right)p'  + g \gamma \overline{\rho} \overline{p} \frac{\partial u'}{\partial x}  = 0 $$$`

and we add these equations to get 


`$$$ \overline{p} \gamma \left(\frac{\partial }{\partial t} + \overline{u} \frac{\partial}{\partial x} \right) \frac{\partial p'}{\partial z} + g \overline{\rho} \left(\frac{\partial }{\partial t} + \overline{u} \frac{\partial }{\partial x} \right)p'  = 0 $$$`
`$$$ \left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right)u'  + \frac{1}{\overline{\rho}} \frac{\partial p'}{\partial x} = 0 $$$`


Which allows us to solve for `$$p'$$` (note we started with 3 equations and 4 unknowns) and then back-substitute to get other values: assume that `$$ p' = \hat{p}\exp(ik(x - ct))$$`, `$$\hat{p}(z=0, \phi) = p_{00}$$` and get


`$$$ \overline{p}\gamma\left( -kc + \overline{u}k \right)\left(\frac{\partial \hat{p}}{\partial z} \right)\Psi + ig\overline{\rho} \left( k\overline{u} - k c\right)\hat{p}\Psi = 0 $$$`

`$$$ \implies ik\overline{p}\gamma\left( \overline{u} -c \right)\left(\frac{\partial \hat{p}}{\partial z} \right)\Psi + ik g\overline{\rho} \left( \overline{u} - c\right)\hat{p}\Psi = 0$$$`

`$$$ \implies \overline{p}\gamma\left(\frac{\partial \hat{p}}{\partial z} \right) +  g\overline{\rho}\hat{p}  = 0 $$$`
`$$$ \implies \left(\frac{\partial \hat{p}}{\partial z} \right)   = -\frac{g\overline{\rho}}{\overline{p}\gamma}\hat{p} $$$`


and we use the ideal gas law to find `$$ \overline{p} = \overline{\rho} R_d \overline{T} \implies \frac{\overline{p}}{\overline{\rho}} =  R_d \overline{T}$$` and therefore

`$$$\left(\frac{\partial \hat{p}}{\partial z} \right) = - \frac{g}{R_d\gamma \overline{T}(z)}\hat{p}$$$`

The righthand size has units Pa/m which agrees with the lefthand side. Clearly this has solution `$$\ln(\hat{p}(z)) - \ln(\hat{p}(z=0)) = - \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z$$` and therefore
`$$$\hat{p}(z) = p_{00}\exp\left(- \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z\right)$$$`

In order to find the physical solution we take

<table class="eqn">
  <tr>
    <td> $$ p' $$ </td> <td>  $$= \Re \left(p_{00}\exp\left(- \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z\right) \exp \left(ik(x - ct) \right)  \right) $$</td>
  </tr>
  <tr>
    <td></td> <td>   $$= p_{00}\exp\left(- \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z\right) \Re \left( \exp \left(ik(x - ct) \right)  \right) $$</td>
  </tr>
  <tr>
    <td></td><td>     $$= p_{00}\exp\left(- \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z\right) \Re \left( \cos(k(x - ct)) + i \sin(k(x - ct)) \right) $$</td>
  </tr>
  <tr>
    <td></td><td>      $$ = p_{00}\exp\left(- \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z\right) \cos(k(x - ct)) $$</td>
  </tr>
</table>
And we use the linearized hydrostatic equation $$\frac{\partial p'}{\partial z} = -\rho' g$$ to find

<table class="eqn">
  <tr>
    <td>$$\rho'$$ </td> <td> $$= -\frac{1}{g} \frac{\partial p'}{\partial z}$$ </td>
  </tr>
  <tr>
    <td></td> <td> $$= - \frac{p_{00}}{R_d\gamma \overline{T}(z)}\exp\left(- \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z\right) \cos(k(x-ct))$$ </td>
  </tr>
</table>


We return to the remaining equation `$$\left(
\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x}\right)u' + \frac{1}{\overline{\rho}} \frac{\partial p'}{\partial x} = 0$$` and assume that `$$u' = \Re \left[\hat{u}(z) \exp(ik(x-ct)) \right]$$` to find

`$$$ (-ikc + i\overline{u}k)\hat{u}(z)\Psi + \frac{1}{\overline{\rho}} (ik) \hat{p} \Psi $$$`
`$$$ \implies (-c + \overline{u})\hat{u}(z) + \frac{\hat{p}}{\overline{\rho}}   $$$`
`$$$ \implies \hat{u}(z)  = - \frac{\hat{p}}{\overline{\rho}( \overline{u}-c)}   $$$`
`$$$    \implies \hat{u}(z)  = - \frac{p_{00}}{\overline{\rho}( \overline{u}(z)-c)} \exp\left(-\frac{g}{R_d\gamma \overline{T}}z\right) \cos(k(x-ct)) $$$`


We also return to the equation `$$ \left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right)p'  + \gamma \overline{p} \frac{\partial u'}{\partial x}  = 0 $$` in order to get a dispersion relation 



<table class="eqn">
  <tr>
    <td>$$0$$ </td> <td> $$= \left(\frac{\partial}{\partial t} + \overline{u} \frac{\partial}{\partial x} \right)p'  + \gamma \overline{p} \frac{\partial u'}{\partial x}$$ </td>
  </tr>
  <tr>
    <td></td> <td> $$ = \left(-ikc + \overline{u}ik  \right)\hat{p}\Psi  - \gamma \overline{p} \frac{ik}{\overline{\rho}(\overline{u} -c)} \hat{p}\Psi$$</td>
  </tr>
  <tr>
    <td></td> <td> $$= \left[\left(-c + \overline{u}  \right)  - \gamma \overline{p} \frac{1}{\overline{\rho}(\overline{u} -c)} \right]\hat{p}\Psi $$ </td>
  </tr>
</table>

And by rearranging this we get `$$$ c = \overline{u} + \sqrt{\gamma R_d \overline{T}} $$$` which agrees with Lamb waves being acoustic


## The conclusions for our data:
`$$p' $$` decays vertically like `$$ \exp\left(- \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z\right) $$`.
We know from the dcmip document that

`$$$T_v(z, \phi) = \frac{1}{\tau_1(z) - \tau_2(z)I_T(\phi)}$$$`
`$$$I_T(\phi) = (\cos \phi)^K - \frac{K}{K+2}(\cos \phi)^{K+2} $$$`
`$$$\tau_{\mathrm{int}, 1}(z) = \frac{1}{\Gamma}\left[\exp\left(\frac{\Gamma z}{T_0} \right) - 1 \right] + z\left(\frac{T_0-T_P}{T_0T_P}\right)\exp\left[-\left( \frac{gz}{bR_dT_0}\right)^2 \right] $$$`
`$$$\tau_{\mathrm{int}, 2}(z) =  \frac{K+2}{2}\left( \frac{T_E-T_P}{T_E T_P}\right)z\exp\left[ -\left( \frac{gz}{bR_dT_0}\right)^2\right]$$$`

Where we note that 

<table class="eqn">
  <tr>
    <td>$$\exp\left(- \int_{z=0}^z\frac{g}{R_d \gamma \overline{T}(z)}\, \mathrm{d}z\right)$$ </td> <td> $$= \exp\left(- \frac{g}{R_d \gamma} \int_{z=0}^z\left[\tau_1(z) - \tau_2(z)I_T(\phi)\right] \, \mathrm{d}z\right)$$ </td>
  </tr>
  <tr>
    <td></td> <td> $$ = \exp\left(- \frac{g}{R_d \gamma} \left[\tau_{\mathrm{int}, 1}(z) - \tau_{\mathrm{int}, 2}(z)I_T(\phi)\right] \right)$$</td>
  </tr>
</table>

and so we want to look for this kind of decay signature in the pressure field.

<span class="todo">

  * SE increased divergence damping --> look for figures
  * Check phase speed of lamb wave
  * FV3 0.25 is probably available
  * DCMIP 2012: gravity wave test case
  
</span>



## Tracking down the actual speed of the wave:

We'll do this in python using Omega 850 masked so that it doesn't catch the baroclinic instability.

### Method:
We're looking at time 6, 12, and 18 hours after start of run.

I'm calculating the maximum value of (signed) `$$\omega_{850} $$` at each time stamp over a small region containing just the 
wave. 

<table class="eqn">
  <tr>
    <th></th>
  <th>
    $$t\in \{3, 4, 5\}$$ ,
  </th>
  <th>
    $$t\in \{6, 7, 8, 9\}$$ ,
  </th>
  <th>
    $$t\in \{10, 11, 12\}$$ ,
  </th>
  </tr>
  <tr>
    <td> $$\phi_{\mathrm{bottom}} =  $$</td> <td>-90 </td> <td>-90 </td> <td>-90 </td> 
  </tr>
  <tr>
    <td> $$\phi_{\mathrm{top}} =  $$</td> <td>90</td> <td>90</td> <td>90</td> 
  </tr>
  <tr>
    <td> $$\lambda_{\mathrm{left}} =  $$</td> <td>150 </td> <td>190 </td>  <td>220 </td>
  </tr>
  <tr>
    <td> $$\lambda_{\mathrm{right}} =  $$</td> <td>220 </td> <td>290</td> 
  </tr>
</table>


And locating the gridpoint at which `$$\omega_{850} $$` is maximized gives

<table class="eqn">
  <tr>
    <th></th>
  <th>
    $$t=3$$ ,
  </th>
  <th>
    $$t=4$$ ,
  </th>
  <th>
    $$t=5$$ 
  </th>
    <th>
    $$t=6$$ 
  </th>
  <th>
    $$t=7$$ 
  </th>
  <th>
    $$t=8$$
  </th>
  <th>
    $$t=9$$ 
  </th>
  <th>
    $$t=10$$ 
  </th>
  <th>
    $$t=11$$ 
  </th>
  <th>
    $$t=12$$ 
  </th>
  </tr>
  <tr>
    <td> $$\phi_{\mathrm{argmax}} =  $$</td> <td>35.1562 </td> <td>34.453</td> <td>27.421</td> <td>21.796</td> <td>12.65</td> <td> 7.0312 </td> <td> 0.0 </td> <td> -8.43</td> <td> -13.35 </td> <td> -21.09 </td>
  </tr>
  <tr>
    <td> $$\lambda_{\mathrm{argmax}} =  $$</td> <td>177.89</td> <td> 191.95</td> <td> 201.09</td> <td> 210.23 </td> <td> 215.85 </td> <td> 224.29 </td> <td> 232.03</td> <td>237.65</td> <td> 246.79 </td> <td> 253.82 </td>
  </tr>
</table>


According to the formula for greatcircle distance `$$$ d_{gc} = a \arccos {\bigl (}\sin \phi _{1}\sin \phi _{2}+\cos \phi _{1}\cos \phi _{2}\cos(\Delta \lambda ){\bigr )}. $$$`

<span class="todo">
Interesting idea: try to zero out u velocity in northern hemisphere, create pure gravity wave that propagates to see if it
  triggers baroclinic development in southern hemisphere?
</span>