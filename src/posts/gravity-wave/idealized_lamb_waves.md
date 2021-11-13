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

Script for tracking speed in an equatorial band:

<details>
<summary>View track_eq_mtn_wave.py</summary>
  
```
import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
from os.path import join
from os import makedirs

#fdir = "/nfs/turbo/cjablono2/owhughes/mountain_test_case_netcdf/lamb_wave_minimal_model"
fdir = "/scratch/cjablono_root/cjablono1/owhughes/CESM_ROOT/output/gravity_wave/cesm_2.1.3.ne60_ne60_mg16.FADIAB.gravity_wave.lamb_wave_minimal_model/run"
#fname = "ne30_1h_output.nc"
fnames = ["ne60_isotherm_equatorial_mountain_temp_270.nc",
          "ne60_equatorial_mountain_temp_315.nc",
          "ne60_equatorial_mountain_temp_360.nc",
          "ne60_equatorial_mountain_temp_450.nc"]
times = [x for x in range(4, 12)]

lambda_max = np.zeros((len(fnames), len(times)))
phi_max = np.zeros_like(lambda_max)
tvals = np.zeros(len(fnames))
for find, fname in enumerate(fnames):
        print(fname)
        ds = xr.open_dataset(join(fdir, fname))
        for ind, tind in enumerate(times):
                bounds = [-10, 10, 130 + 10 * tind, 200 + 10 * tind]
                lons = ds['lon']
                lon_mask = np.logical_and(lons > bounds[2], lons < bounds[3])
                lats = ds['lat']
                lat_mask = np.logical_and(lats > bounds[0], lats < bounds[1])
                print(tind)
                omega850 = ds['OMEGA850'][tind*4, :, :]
                omega850 = omega850.where(lat_mask).where(lon_mask)
                res = omega850.argmax(dim=("lat", "lon"))
                latmax = (omega850.lat[res['lat']].values)
                lonmax = (omega850.lon[res['lon']].values)
                lambda_max[find, ind] = lonmax
                phi_max[find, ind] = latmax
                plt.figure()
                ax = plt.axes(projection=ccrs.PlateCarree())
                plt.contourf(lons.where(lon_mask), lats.where(lat_mask), omega850,
                        transform=ccrs.PlateCarree())
                plt.text(lonmax, latmax, 'Max',c="white",
                        horizontalalignment='center',
                        transform=ccrs.PlateCarree())
                makedirs("figures", exist_ok=True)
                plt.savefig(f"figures/{find}_{tind}_omega.pdf")
                plt.close()
        tvals[find] = ds.isel(indexers={"time": [0]})["T850"].where(lat_mask).where(lon_mask).mean()





a = 6371e3 #km
dt = 60 * 60 
gamma = 1003/(1003 - 287.3)
Rd = 287.3


lambda_max = np.deg2rad(lambda_max)
phi_max = np.deg2rad(phi_max)
print("predicted speeds: ")
compute = np.sqrt(gamma * tvals * Rd)
print(compute)


gc = a * np.arccos(np.sin(phi_max[:, 1:]) * np.sin(phi_max[:, :-1]) + np.cos(phi_max[:, 1:]) * np.cos(phi_max[:, :-1]) * np.cos(lambda_max[:, 1:] - lambda_max[:, :-1]))
gc_one = a * np.arccos(np.sin(phi_max[:,  1]) * np.sin(phi_max[:,  7]) + np.cos(phi_max[:,  1]) * np.cos(phi_max[:,  7]) * np.cos(lambda_max[:,  1] - lambda_max[:,  7]))
print("calculated speeds: ")
print(gc/dt)
print(gc_one/(6 * dt))
  
```
  
  
</details>

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





### Testing the wave in an approximately isothermal atmosphere

Use the same setup as in the previous section with the equatorial mountain. Set `$$\Gamma = 0.00005 \mathrm{K}/\mathrm{m} $$`.
Track it using the same script as the previous section. Note: the third row shows
  speeds calculated using the _minimum_ `$$ \omega_{850}

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
  </tr>
  <tr>
    <td> $$c_{\mathrm{predicted}, 850\mathrm{hPa}} $$</td> <td>325.8 </td> <td>352.0</td>  <td>380.67 </td> <td>403.76</td>
  </tr>
  <tr>
    <td> $$c_{\mathrm{measured}, 850\mathrm{hPa}}  $$</td> <td>332.37 </td> <td> 351.12 </td> <td> 372.83 </td> <td> 394.95 </td>
  </tr>
</table>
  


  
  
### Creating an FV model run for comparison:

In the FV model there is _no signature what so ever_ at day 10! If you set the colorbar range
to `[-0.005, 0.005]` at hour 2, you can see the signature of this wave propagating and decaying 
exponentially(?).

