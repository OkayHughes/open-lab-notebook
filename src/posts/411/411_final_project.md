---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: climate411
  key: Final project 411
layout: layouts/post.njk
---



# Notes on "The Mixed-Phase arctic cloud experiment"

* Arctic model scatter larger than other regions (ca 2007)
* "weak solar heating coupled with strong inversions and a combination of sea ice and ocean at the lower boundary produce clouds iwth multiple layersd and stable temp profiles"
* Why doesnt WBF cause rapid dissipation? Clouds long lived"
* Arm mpace: 27 sept 2004 to 22 oct 2004
* North slope of AK DOE installation
* Both ground based and radiosondes (twice daily) taken
* Three weather modes observed
* Several exemplary cases: 
  * 9-11 oct boundary layer stratocumulus
  * cirrus on 17 october
  * Multi-layer stratus on 6 oct
* radar reflectivity plot

# Notes on Intercomparison of Model Simulations of mixed-phase clouds observed during the ARM MPACE experiment. I: single layer cloud
* Little dependence on temperature for liquid vs ice in arctic clouds
* Mixed phase clouds optically thicker than glaciated clouds.
* Modeling studies: mixed phase clouds sensitive to ice crystal number concentration
* Ice formation mechanisms in these clouds is actually unresolved (frindlind 2007)
* Both single-column models and cloud resolving models
* Synoptic conditions: north-easterly flow around an anticyclone.
* Surface heat/WV fluxes from ocean induce boundary layer clouds. (rolls/cloud streets)
  * Fig 1: aerial picture of clouds
* boundary layer between 1 to 1.5 km deep
* Much more liquid water path than ice
* Weak inversion at top of BL
* Good summary of how data was turned into number concentrations and cloud phase characterization


## modeling:
* Initial conditions:
  * cloud-topped boundary layer 
  * well mixed and capped by inversion
  * Figure 2: how well do sounding and initial condtions match?
  * Cloud top initially pure liquid
  * Temperature and water mixing ration advection calculated from ECMWF reanalysis data
  * No _in-situ_ observations of surface fluxes. Taken from ECMWF data
* Consistent with turbulent boundary layer profiles
  * Seems consistent with 0.8m/s vertical velocity in the cloud 
  * Radiation was provided radiation parameterization
* Aerosol distribution:
  * bimodal log-normal distribution
  * Assumed to be ammonium bisuphate ??
* Ice nuclei:
  * Citation data measures ice nuclei < 2 um acting in deposition, condensation, frezing, and immersion freezing modes. Contact mode not possible
  * 85% of measurements less than 0.1 #/L
  * Fun tables: might be able to do a little comedy here
* Single vs double moment schemes?
* Bin resolved microphysics?
### modeling schemes
* Single moment with t-dependent partitioning
  * Single variable that encodes condensate
  * Temperature dependent function that partitions into liquid/ice
* Single moment with independent liquid and ice
  * Separate prognistic variables for liquid and ice concentration, not soelly function of temperature
  * Assume starts as water and transitons via e.g. riming, droplet freezing, or WBF
* Double moment schemes
  * Contains distribution of mass as well as concentration number.
  * Allows for physically-based coupling of clouds with aerosols
  * All two moment in this study have a number concentration for small ice particles
* Bin resolved methods:
  * Number concentration bins are explicitly represented (O(20) bins)
  * Rare, expensive
* WBF representation
  * Single moment t-dependent schemes cannot represent
  * 