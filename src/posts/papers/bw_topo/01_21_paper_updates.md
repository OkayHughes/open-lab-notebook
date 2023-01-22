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
configuration used in the paper. None of them are a perfect match, but 

