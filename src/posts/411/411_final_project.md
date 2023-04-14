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
[slides](https://docs.google.com/presentation/d/12agCNKsJoHnD_ICWMAn_TWoGNf_EHGE9IHbgeFB1gew/edit#slide=id.g22df6b82993_0_19)
Outline for presentation:
* Focus on cam5/cam6 
* What changed? What do parameterizations cover
* Comedy: Most boring food imaginable and it hasn't manged to model it 

To find: Gettelman 2010
* Mixed phase physical processes

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
  * Double moment schemes do
* In double moment schemes, primary ice nucleation is dominant. SIP is sometimes represented.

## results:
* All produce precipitating cloud.
* Fig 7: Wildly varying ice/liquid water path
* Best guess of lwp: 160 pm 50 g/m^2 
* best guess of iwp: alpha * 15 g/m^2 (1/2 < alpha < 2)
* Median double moment do better. But a significant fraction of double moment significantly underestimate
  * Increasing complexity seems to do better _in the median_ but doesn't guarantee a good simulation
### microphysics
* Ice crystals 2 #/L >> 0.16 #/L inp.
* Expect liquid water path inversely related to ice crystal number conc
* Not found.
* Fig 10: Huge variability inrelation between number conentration and liquid water path
* Note: both median SCM and CRMs significantly underestimate LWP --> extra fidelity in CRMs maybe doesn't buy you anything?
* This is about the simplest mixed phase cloud you can represent, but models still shit the bed.

# Notes on Testing CLoud Microphysics Parameterizations in NCAR CAM5 with M-PACE observations
* CAM 3 had single-moment microphysics.
* But CAM 5 has double moment microphysics
* Double moment schemes allow cloud properties to be physically coupled to aerosols
* CAM 5 with FV dycore at f19 resolution, 
* Initialized with MERRA data beginning of each day for M-PACE
* Modal aerosol module: 
  * MAM activates aerosols with appropriate properties to be CCN/INP and generates droplets and ice crystals
  * Interactive aerosol effects on both warm and cold clouds
* Microphysics predicts both number and mass concentration for ice and water
* precipitation in ice and snow is diagnosed
* Particle distributions treated as gamma functions
* Temperature of homogeneous freezing increased form -40C to -5C in released cam 5 to tune arctic surface flux
  * Excuse me? 
* Ice nucleation:
  * Supersaturation wrt ice dealt with by performing saturation adjustment for only liquid clouds
  * Process-rate calculations to deal with WBF
  * Aerosol properties used in ice nucleation
  * Contact freezing with mineral dust and Hallet-Mossop SIP are included 
* Alternative IN parameterization:
  * Ice crystal habits hard to determine in clouds due to e.g. shattering 
  * INP regularly <0.1% of aerosols present.
  * Meyers '92 parameterization overestimates production.
  * Ice number concentrations are diagnosed: implicit sources of INs that replenish even after scavenging
  * Empirical relationships between Ice Number and surface area densities of aerosols by temperature. factor of ten less IN
## results
* Figure 7:
* CAM5 overestimates LWC by 70% and IWC by factor of 2
* Change to phillips increases LWC by 20%, IWP unchanged
* Underestimates LWP for all cloud types in MPACE study.
* CAM5 significnatly underestimates downward LW radiative fluxes by 20-40 w/m^2 due to underestimate of cloud liquid mixing ratio
* Compared to CAM3 MPACE, CAM5 better simulates cloud fraction fo single layer BL clouds. But CAM 3 has significantly higher cloud liquid water content
  * Overall CAM5 has diminished radiative flux biases.
## sensitivity tests:
* Turn off direct conversion of cloud liquid to snow
  * Two methods: collection of clou dliquid by snow
  * Deposition onto snow through WBF.
* Small changes in cloud water path.
* Freezing of raindrops: 
  * Heterogeneous freezing of rain by immersion freezing
  * Homogeneous freezing of rain to form snow instantly at -40C (changed to -5C in cam5 release)
  * Clouds in MPACE ranged from -9 to -16, so homogeneous freezing could occur in these clouds
* Fixing this threshold results in drastic increase in LWP and IWP that is much closer to averaged values from MPACE
* Reduce IN using phillips scheme + fix homogeneous threshold:
  * WBF process slowed substantially 
  * Lower snow production from cloud ice as well. Cloud liquid increases 50-100%
* CAM5 severely understimates AOD according to ARM data.
## summary:
* CAM5 produces too low cloud liquid water mxing ratio and underestimates LWP 
  * Much better at IWP and ice water content.
  Surface longwave radiation flux underestimated by 20-40W/m^2
* Two moment scheme qualitatively reproduces increasing trend of liquid fraction of total water with altitude for single layer mixed clouds.
* IN parameterization changes show very slight improvement.



# Notes on Impacts of representing heterogenous distribution of cloud liuqid and ice on phase parititioning of arctic mixed clouds with CAM5

* Complex interactions betwee cloud microphysics, cloud-top radiative cooling, turbulent mixing, and surface coupling enable 
arctic misced-pahse clouds to persist up to several days

* Discrepancy between concentration of INPs and number of cloud ice particles not fully understood
* Reducing the INP concentration can drastically improve LWP representation by slowing down WBF
* Mixed-phase clouds are likely spatially heterogeneous (pockets of ice/water) on the scale of 10^2 m
  * Separation of ice from water also slows WBF 
* In this study: replace Meyers IN parameterization with calssical nucleation theory
  * Nucleation is stochastic, depends on number and size of aerosol particles
* Eqn 1: WBF rate constant
  * Note: WBF directly converts cloud liquid water to cloud ice and snow without passing through evaporation first
* New WBF:
  * WBF process largely depends on contact volume between supercooled liquid droplets and ice crystals 
  * Typical contact volume in homogeneous gridcell:10^3*10^5*10^5
  * in heterogenous grid cell: 10*10^3*10^3 if 100 m pockets of liquid and ice butt against each other.
  * Relaxation timescale is inversely proportional to contact volume.
* Mass weighted water vapor:
  * Certain work indicates RH in mixed phase clouds indicate RH should be close to 100%.
  * Heterogeneity could explain observed deviance from the SVP expected if ice and snow are homogeneously mixed.
* Fig 1: structure of cloud shown nicely
  * cloud base too low, possibly due to boundary cpnditions in SCM
* All modifications to WBF increase LWC (which is negiligibel in ctl)
  * Figure 2: quite good (probably include)
* Figure 4: comparable to figures from other paper
  * Most aggressive slowdown in WBF still underestimates LWC by factor of two.
* Figure 6: Breakdown by microphysical process
  * liquid water detrailment from shallow convection is liquid source in ctrl
  * WBF process major sink in CTL
  * Note: WBF is separate from 
* Figure 8: 
  * If you also decrease accretion rate of liquid rain by snow by same amount as WBF, then you match LWC
  * High enough vertical resolution is crucial for maintenance of cloud liquid layers!

# Notes on Impacts of SIP on Arctic mixed-phase clouds based on ARM observations and CAM6 single-column model simulations
* Mixed phase clouds microphysically unstable
* Can be fully glaciated in a few hours by WBF
* AMPC: liquid water at cloud top and ice water undeneath
* Low cocnentrations of ice particles only at cloud base
* CAM6 sees introduction of Clubb: cloud layers unified by binormals 
  * Treats boundary layer turbulence, shallow convection.
  * CNT in clubb relates ice production to mineral dust and black carbon
* New double-moment scheme
  * includes rime splintering 
  * heterogeneous feezing of droplets, homogeneous freezing below -40
  
## their SIP scheme:
* Pseudo-bin approach
### Ice-ice fragmentation
* Combinr particle kinetic energy and ice habits, which can be explained by temperature, particle size, and riming. 
* Eq 2: new particles per collision
  * Three types of collision: cloud ice/snow with hail/graupel
  * ice/snow ice/snow
  * hail/graupel hail/graupel (ommitted due to CESM not doing graupel)
* Collisions calculated per bin
### Droplet shattering during rain freezing
* Droplet shatter depends on weightof raindrops and ice particles
* Two modes:
* Mode 1: freezing rain runs into smaller particle. form big "shards" or tiny "splinters"
* Mode 2: collides with bigger particle 
### Rime splintering:
* Included in MG 2015
* Hallett-Mossop process
  * Bunch of parameters
## results:
* Note: by this point they had identified that data collected during MPACE had significant shattering artifacts increasing the ice particle number conentration by up to factor of 5-10
* IWP is smaller than 50g m^-2 in CTL but up to 500g m^-2 in measurements. 
* SIP_PHIL shows decreased LWP and increased IWP compared with ctl
* Figure 6: IWC/LWC 
* Cloud  base height still too low
* In SIP_PHIL, IWC is 4x larger than in ctl
* SIP increases ICNC by up to 5 #/L
* Fig 8: SIP pie charts
* Fig 11: ICNC pdf