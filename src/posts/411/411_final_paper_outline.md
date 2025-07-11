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

Introduction:


# Observational background

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
  * Above-clouddeck flights combined with in-situ measurements constrain both radiative budget at cloud boundary as well as concentration of species in cloud
* 27 sept 2004 to 22 oct 2004
* Three separate exemplary clouds. 
* Main event for us: Single layer stratoform mixed phase
  * High pressure over ice pack
  * transient low draws moisture to NSA site. 
* 9-11 of october: single layer stratus cloud
* Low level northeasterly flow off the ipack ice and over ocean. Persistent low-level clouds under a sharp inversion for entire period
* Include: Figure 6 is ground truth. 
  * Ice precipitation indicated persistently underneath cloud base
  * Cloud base at 900m.
* Cloud top values for temperature, liquid water content, mean diameter were -16.9C, 0.36g/m^3, 25 um.
  * Number concentration 25 #/cm^3 throughout
* Figure 7: explains background state given above
* Narrow cloud drop distribution. Heterogeneous ice crystals through entire cloud body.
* Mixed phase present even with cloud-top temperatures as low as -30C


*  Fig 1 [MPACE_MIP]: aerial picture of clouds

  
# Modeling Background
* Retrievals from this stratiform cloud case were used to create cloud physical and dynamical fluxes
 * mm wavelength cloud radar
 * lidar, microwave radiometer.
* Fields: 
  * cloud top/base
  * liquid water/ice water content
  * effective particle sizes of liquid/ice
* Uncertainties:
  * 20g/m^-2 for liquid water path
  * ice water content: 0.002 g/m^-3 based on minimal detectable radar signal (dubious)
* well mixed and capped by inversion
* cloud-topped boundary layer 
* Cloud top initially pure liquid
* Temperature and water mixing ration advection calculated from ECMWF reanalysis data
* No _in-situ_ observations of surface fluxes. Taken from ECMWF data
* Focus on single-vs-double moment schemes:
  * Mixed-phase processes such as the Wegener Bergeron Findeisen process rely on ice crystal concentration number
  * Single moment schemes have only mass, not number concentration
  * 10 SCMs with single moment and 10 with double-moment schemes in this paper
  * Discussion of bin microphysics schemes beyond scope of this paper
* Table IV: 
* 160 pm 60 g/m^2 for liquid water and 7-30 g /m^2 of ice water path.
  * Aircraft IWP much higher than remote sensing IWP
* Single model with T-dep ice/liquid partitioning: 21.2 g/m^2
* Single moment but separate ice/water microphysics: 72.8 g/m^2
* double moment: 100 g/m^2 
* Ice water path: 33.8, 31.8, 19.9
  * That is, models with higher-complexity treatment of ice microphysics are closer to observed values.
  * Figure 8: water content vs aircraft retrievals, ice water vs retrievals
  * LWC 
  * Figure 10: ICNC vs liquid water path: absurd scatter across models (should include this)
  * No agreement about ICNC
  
High degree of heterogeneity among models. Even those that share, e.g., a double moment scheme.


# Modeling Interventions

# Summary of CAM5

* CAM 3 had single-moment microphysics.
* But CAM 5 has double moment microphysics
  * Microphysics predicts both number and mass concentration for ice and water
  * precipitation in ice and snow is diagnosed (from what?)
  * Particle distributions treated as gamma functions

* Double moment schemes allow cloud properties to be physically coupled to aerosols
* Modal aerosol module: 
  * MAM activates aerosols with appropriate properties to be CCN/INP and generates droplets and ice crystals
  * Interactive aerosol effects on both warm and cold clouds
* Separate WBF for ice crystals/snow (four fields)
* CAM 5 with FV dycore at f19 resolution,
* Initialized with MERRA data beginning of each day for M-PACE
* Temperature of homogeneous freezing (but only for rain!) increased form -40C to -5C in released cam 5 to tune arctic surface flux

* Ice nucleation linked with aerosol properties in this model 
  * Homogeneous nucleation of sulfate competing with heterogeneous nucleation in mineral dust for ice clouds.
  * Mixed phase clouds: deposition/condensation nucleation drawn from Meyers 1992
  * Constant IN concentration for T<-20C
  * Contact freezing by mineral dust, and Hallet-Mossop SIP are included. 
  * Immersion of cloud freezing is included.
* Limitations of Meyers parameterization:
  * Constant amount of IN means that particles are implicitly replenished when ice crystals scavenge INPs.
  * Shown in Prenni '07 that Meyers produces too many IN for MPACE case (might be worth a note)
* Purpose of this study:
  * What happens when Meyers is changed out for Phillips IN scheme
  - Empirically derived relationship between mineral dust, black carbon, and hydrophobic organics with temperature
## Results:
* CAM5 underestimates LWC by 70% and overestimates IWC by factor of 2
* Figure 6 (qualitative over/under estimates)
* Figure 7: cloud fraction is good, but persistent biases in LWC, IWC
* From 5-12th october, cam5 undreestimates downward LW radiative fluxes by 20-40 W/m^2
  * Largely due to underestimate of cloud liquid mixing ratio
  * Overestimates OLWR by 10 W m^2
* Two processes for turning cloud liquid into snow in CAM5:
  * Collection of water by snow
  * Evaporation/deposition by WBF
* Figure 10: Ice/Water Budgets
  * Fixing instantaneous freezing fixes budget substantially
* Cam5 significantly underestimates aerosol optical depth (is this reanalysis artifact?)
* Tuning parameter for autoconversion from 
## WBF
* Mixed-phase clouds are likely spatially heterogeneous (pockets of ice/water) on the scale of 10^2 m
  * Separation of ice from water also slows WBF 
* In this study: replace Meyers IN parameterization with calssical nucleation theory
  * Nucleation is stochastic, depends on number and size of aerosol particles
  * Note: different from above. Same goal
* New WBF:
  * WBF process largely depends on contact volume between supercooled liquid droplets and ice crystals 
  * Typical contact volume in homogeneous gridcell:10^3*10^5*10^5
  * in heterogenous grid cell: 10*10^3*10^3 if 100 m pockets of liquid and ice butt against each other.
  * Relaxation timescale is inversely proportional to contact volume.
* Mass weighted water vapor:
  * Certain work indicates RH in mixed phase clouds indicate RH should be close to 100%.
  * Heterogeneity could explain observed deviance from the SVP expected if ice and snow are homogeneously mixed.
* Figure 4: comparable to figures from other paper
  * Most aggressive slowdown in WBF still underestimates LWC by factor of two.
* Figure 6: Breakdown by microphysical process
  * liquid water detrailment from shallow convection is liquid source in ctrl
  * WBF process major sink in CTL
* Figure 8: 
  * If you also decrease accretion rate of liquid rain by snow by same amount as WBF, then you match LWC
  * High enough vertical resolution is crucial for maintenance of cloud liquid layers!
* Recommendation:
  * Physically based representation of heterogeneous structure rather than tuning parameter.
## Integrated sensitivity


# Conclusions
* Bin microphysics and SIP
  
  
  
  
Lonely science: can it be studied in isolation?
