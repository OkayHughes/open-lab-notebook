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


I used the following script
<details>
<summary>View track_gw_speed.py</summary>
  
```
import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
from os.path import join


fdir = "/nfs/turbo/cjablono2/owhughes/mountain_test_case_netcdf/"
fname = "ne30_1h_output.nc"

ne30_ds = xr.open_dataset(join(fdir, fname))
t =  12
t0 = 2

bounds = [[-90, 90, 150, 220], [-90, 90, 150, 220], [-90, 90, 150, 220], [-90, 90, 150, 220],
	  [-90, 90, 190, 260], [-90, 90, 190, 260], [-90, 90, 190, 260], [-90, 90, 190, 260],
	  [-90, 90, 220, 290], [-90, 90, 220, 290], [-90, 90, 220, 290] ]
lons = ne30_ds['lon']
lon_mask = np.logical_and(lons > bounds[ (t-t0)][2], lons < bounds[ (t-t0)][3])
lats = ne30_ds['lat']
lat_mask = np.logical_and(lats > bounds[ (t-t0)][0], lats < bounds[ (t-t0)][1]) 
print(ne30_ds['time'][2 * t])
omega850 = ne30_ds['OMEGA850'][2 * t, :, :] #- ne30_ds['OMEGA850'][1, :, :]
omega850 = omega850.where(lat_mask).where(lon_mask)
res = omega850.argmax(dim=("lat", "lon"))
latmax = (omega850.lat[res['lat']].values)
lonmax = (omega850.lon[res['lon']].values)

print(f"lat: {latmax}, lon:{lonmax}")
plt.figure()


ax = plt.axes(projection=ccrs.PlateCarree())

plt.contourf(lons.where(lon_mask), lats.where(lat_mask), omega850,
             transform=ccrs.PlateCarree())
plt.text(lonmax, latmax, 'Max',c="white",
         horizontalalignment='center',
         transform=ccrs.PlateCarree())

a = 6371 #km


plt.savefig(f"{t}_omega_test.pdf")
  
  
```
</details>
  
  
<details>
<summary>View comp_gw_speed.py</summary>
  
```
import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
from os.path import join

fdir = "/nfs/turbo/cjablono2/owhughes/mountain_test_case_netcdf/"
fname = "ne30_1h_output.nc"

ne30_ds = xr.open_dataset(join(fdir, fname))

a = 6371e3 #km
dt = 60 * 60
gamma = 1003/(1003 - 287.3)
Rd = 287.3

lambdamax = np.array([177.89, 191.95, 201.09, 210.23, 215.85, 224.29, 232.03, 237.65, 246.79, 253.82 ])
phimax = np.array([35.1562, 34.453, 27.421, 21.796, 12.65, 7.0312, 0.0, -8.43, -13.35, -21.09])
print(ne30_ds['lon'])
subset = ne30_ds.isel(indexers={"time": [0],
			       }).sel(indexers={"lon": lambdamax, "lat": phimax}, method="nearest")
lambdamax = np.deg2rad(lambdamax)
phimax = np.deg2rad(phimax)
T = subset["T850"]
u = subset["U850"]
print("predicted speeds: ")
print(u + np.sqrt(gamma * T * Rd))

gc = a * np.arccos(np.sin(phimax[1:]) * np.sin(phimax[:-1]) + np.cos(phimax[1:]) * np.cos(phimax[:-1]) * np.cos(lambdamax[1:] - lambdamax[:-1]))

print("calculated speeds: ")
print(gc/dt)
  
```
</details>
  
  
Ok so computing this `$$c = \overline{u} + \sqrt{\gamma R_d \overline{T}} $$`. Taking `$$ \overline{T} = 280 \mathrm{K} $$`
and in the lower atmosphere `$$ \overline{u} \approx 10\mathrm{m}/\mathrm{s} $$`, and `$$ \gamma = 1003  / (1003 - 287.3) = 1.40 $$`, and `$$ R_d = 287.3 \mathrm{J}\cdot \mathrm{kg}^{-1}\cdot \mathrm{K}^{-1} $$`
we therefore find that `$$$ c = 10\mathrm{m}/\mathrm{s} + \sqrt{1.4 \cdot 280 \mathrm{K} \cdot 287.3 \mathrm{J}\cdot \mathrm{kg}^{-1} \cdot \mathrm{K}^{-1}} = 345.5 \mathrm{m}/\mathrm{s}.$$$`
  
  
The calculated speeds of the wave from the scripts above vary from `$$ 356.95 \mathrm{m}/\mathrm{s} $$` at hour 3, and
  `$$ 316.35 \mathrm{m}/\mathrm{s}.$$` at hour 12
  
This seems to be compatible. This is deeply curious to me, as it indicates that the wave may be acoustic?
  

Idea: increase temperature by 90 degrees, i.e. `$$ T_E = 400\mathrm{K} ,\ T_P = 330 \mathrm{K} $$`
  
## Propagation under increased temperature
  
  
  In this case `latmax = [33.0468, 30.937, 22.5, 14.062, 7.031, 0.7031, -11.95, -19.68, -24.60, -32.34] `, 
  `lonmax = [182.812, 197.57, 206.71, 215.85, 224.29, 234.84, 237.65, 246.79, 258.75, 269.29]`
  
  Using the same calculation as above, we find that the calculated speeds are between `$$391 \mathrm{m} / \mathrm{s} $$` and 
  `$$ 372 \mathrm{m} / \mathrm{s} $$` at time 6.
  
  Under a `$$ 90^\circ\mathrm{C} $$` change in temperature, 
  `$$$ c = 10\mathrm{m}/\mathrm{s} + \sqrt{1.4 \cdot 370 \mathrm{K} \cdot 287.3 \mathrm{J}\cdot \mathrm{kg}^{-1} \cdot \mathrm{K}^{-1}} = 395.5 \mathrm{m}/\mathrm{s}.$$$`
  
Without being very careful to check whether changing the two temperature parameters changes anything else, this indicates
  that we might expect about a `$$ + 50 \mathrm{m}/\mathrm{s} $$` change in wave speed. This once again seems consistent.
  
  Something important to note: changing the temperature creates an increase in the strength of the zonal jet. This 
  complicates things somewhat.
  
With `$$ T + 45\mathrm{K} $$`: `latmax = [33.04, 30.23, 24.60]`, `lonmax = [180.0, 192.65, 203.90]`
  
* Todo: divergence damping redo 
* read lin again
  
  
## Increasing divergence damping in the SE model:

  If this were actually a gravity wave, we would expect that increasing divergence damping would severely
curtail the ability of the wave to propagate (see lecture notes on gravity waves). In order to test this
  we increase `se_nu_div` from `$$0.1 \times 10^{16} $$` by a factor of 4 to `$$0.1 \times 10^{16} $$`

<span class="figure">
<img class="small" alt="Omega 850 day 0.25" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/se_nu_div_inc/OMEGA1.png">
<img class="small" alt="Omega 850 day 0.75" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/se_nu_div_inc/OMEGA3.png">
<img class="small" alt="Omega 850 day 1.25" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/se_nu_div_inc/OMEGA5.png">
</span>
  
  

  