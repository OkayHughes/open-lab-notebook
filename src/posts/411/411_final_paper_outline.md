---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: climate411
  key: Final paper 411
layout: layouts/post.njk
---
Final concentration: Correcting LWP and IWP biases for Arctic mixed-phase clouds in CAM5



## physics of AMPCs
* Mixed phase clouds at warm temperatures (which??) are microphysically unstable. [RESILIENCE]
  * WBF can glaciate in hours
  * But observations of mixed phase clouds show they can persist for days or weeks.
  * Arctic MPCs different (HOW?)
## Replenishing moisture
* Turbulence and cloud-scale upward air motion seem to be critical in maintaining mixed-phase clouds under weak synoptic-scale updrafts [RESILIENCE]
* Strong enough updrafts -> supersaturated w.r.t. ice and water (both grow simultaneously) [RESILIENCE]
* supercooled droplets lead to strong longwave radiative cooling (60K per day near cloud top whoa)
* Coupling to synoptic conditions: Large scale advection creates frequent moisture inversions near cloud top
* Entrainment of above-cloud air actually replenishes cloud water lost to (ice) precip
* Unlike lower latitudes, Special: AMPCs can persist and be replenished even if not dynamically coupled to surface fluxes
* "Weak solar heating, coupled with strong inversions and and a combination of sea ice and ocean at the lower boundary procude clouds with stable temperature profiles" [MPACE]
## Surface coupling:
* Radiative cooling of SC water warms surface, cools atmosphere
* Source of static instability: sensible heat flux and moisture drawn upwards into cloud
* Ice often only forms after SC water is present (even if there is substantial ice-supersaturation before LW is present)
* Modeling of these clouds is tremendously difficult [RESILIENCE] last paragraph

These clouds are complex to model

## Measuring AMPCs
* Atmospheric Radiation Measurement program set up in alaska:
  * Barrow (another name) -> oliktok point 0> toolik lake 0->  atqasuk
  * Approximates grid cell of GCM, for use in the Single Column Modeling methodology
* Barrow site:
  * High Spectral Resolution Lidar
  * depolarization lidar
  * Atmospheric Emitted Radiance Interferometer
  * Instrumented aircrafts 
  * Citation
  * High Volume Precipitation Sampler
  * Counterflow Virtaul Impactor
  * Continuous flow ice thermal diffusion chamber. 
  * Above-clouddeck flights combined with in-situ measurements constrain both radiative budget at clonstituent concentrations in the cloud

Highly complex. How do we benchmark?
ARM MPACE:
* Frequently occurring
* Take measurements of, what exactly?
  * Notes on what is high reliability (LIDAR, RADAR)
  * Note on post processing
  * Ice number concentration: suspect

Modelling is difficult: 
* All models (at the time) tended to have similar underrepresentation.
  * Model complexity improves potential to represent clouds, but doesn't guarantee good performance.
* CAM5: how does it treat?
  * Double moment scheme. Four quantities (water, ice, rain, snow)
  * The two WBFs
  * Three-mode aerosol scheme: what gets treated as IN.
  * Implict homogeneity
  

  
  
  
  
Lonely science: can it be studied in isolation?
