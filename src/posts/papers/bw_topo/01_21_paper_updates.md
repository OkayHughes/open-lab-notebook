---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: updates 01 21
  parent: Baroclinic Wave Test Case with Topography
layout: layouts/post.njk
---



## Omega plots

<span class="row">
<img class="small"  src="https://open-lab-notebook-assets.glitch.me/assets/paper_update/original_color_scheme_omega.png">
<img class="small"  src="https://open-lab-notebook-assets.glitch.me/assets/paper_update/saturated_color_scheme_omega.png">
</span>

I plotted the paper data using the longitude range used in the AWMG talk. 
Note the different color schemes: on the left is the color scheme currently used in the paper.
On the right is the color scheme used in the AWMG talk. 
When the color scheme from AWMG is used, the plot looks basically the same as the one in the power point. At least, I think so.


## FV3 discrepancy:

<span class="row">
  <img class="small" src="https://open-lab-notebook-assets.glitch.me/assets/paper_updates/fv3_psl/january_23_paper_plot.png">
  <img class="small" src="https://open-lab-notebook-assets.glitch.me/assets/paper_updates/fv3_psl/awmg_psl_plot.png">
</span>
Left: plot of PSL at day 5 using FV3 data that is currently in the Zenodo archive and for all the paper plots.
Right: plot of PSL at day 5 taken from the AWMG talk which shows less intensification.

<span class="row">
    <img class="small" src="https://open-lab-notebook-assets.glitch.me/assets/paper_updates/fv3_psl/all_PSL_cj_fv3_data_hord5.png">
    <img class="small" src="https://open-lab-notebook-assets.glitch.me/assets/paper_updates/fv3_psl/all_PSL_cj_fv3_data_hord6.png">
    <img class="small" src="https://open-lab-notebook-assets.glitch.me/assets/paper_updates/fv3_psl/all_PSL_cj_fv3_data_hord10.png">
</span>
These plots are generated using the netcdf files stored at `/nfs/turbo/cjablono2/cjablono/fv3`. What we can see from these plots is that the major change is that
This leads me to suspect that the diffusion settings used in the model run shown in the AWMG talk is more diffusive than the current 
configuration used in the paper. I am unsure if the runs stored in your scratch use a different configuration than mine.
This does confirm that the namelist settings have changed from the AWMG talk, which is consistent with using a more updated
FV3 branch when it became available.

## Determining the discrepancy in the minimum MSLP plot of FV3 when MPAS is swapped out.
Changing back to the original MPAS data doesn't affect the visible difference between the PSL minimum time series in the paper
and what I'm generating now. I'm redoing the FV3 simulation and regrid to see if that changes it. I am wondering if I 
switched from a one-degree interpolation to a half-degree interpolation at some point. I may have accidentally been generating plots with C192 data
interpolated to a 1 degree grid initially. 





## Changing the longitudinal extent for figure 11 
Before I finish putting these modifications in place for figure 11, I wanted to ask your opinion. Given the pictures of `$$\omega$$` shown above,
does viewing this much longitude make it hard to see the differences between the dynamical cores? To me this feels very cramped.
Should I try 


## Expanding the stop date of the dry PSL time series
Here's why I'm falling behind on the plots I need to generate. The interface for `/nfs/locker` has disappeared.
It appears that globus is now the only way to transfer data out of locker into scratch. This is an annoying process.
First I set up a globus account and authorizing it to use my umich email for authentication. 
I did it so I could access [this site](https://app.globus.org/file-manager?origin_id=824d7a3d-c8dc-42eb-aa8f-c9cbf5101669).
The UUID needed to transfer our files from locker into, for example, scratch, is `824d7a3d-c8dc-42eb-aa8f-c9cbf5101669`.
On greatlakes, run `module load globus-cli`.
I set the environment variable `GLOBUS_LOCKER` to this value.
One can do something like `globus ls $GLOBUS_LOCKER:/clasp-cjablono/owhughes/mountain_test_case_netcdf` to see all files in the locker directory.
One can then try to do `globus transfer $GLOBUS_LOCKER:/clasp-cjablono/owhughes/mountain_test_case_netcdf/dry_ne240.nc $GLOBUS_GREATLAKES:$scratch/dry_ne240.nc`.
First, this will prompt you to authenticate `globus-cli` so it has access to the `$GLOBUS_LOCKER` collection.
Second, it will initiate a transfer from the locker storage to the `$scratch` directory on greatlakes.


<span class="row">
  <img class="medium" src="https://open-lab-notebook-assets.glitch.me/assets/paper_update/SE.ps_max_time_series_8days_0.5deg_dry.png">
  <img class="medium" src="https://open-lab-notebook-assets.glitch.me/assets/paper_update/SE.ps_min_time_series_8days_0.5deg_dry.png">
</span>
I'm inclined to ignore the "maximum MSLP" plot.

## MPAS vertical velocity: why is it so wrong?
Still haven't had time to think about this.




