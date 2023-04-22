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



# Notes on "The Mixed-Phase arctic cloud experiment" [MPACE]

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

# Notes on Intercomparison of Model Simulations of mixed-phase clouds observed during the ARM MPACE experiment. I: single layer cloud [MPACE_MIP]
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

# Notes on Testing CLoud Microphysics Parameterizations in NCAR CAM5 with M-PACE observations [CAM_IN]

* CAM 5 with FV dycore at f19 resolution, 
* Initialized with MERRA data beginning of each day for M-PACE
* Modal aerosol module: 
  * MAM activates aerosols with appropriate properties to be CCN/INP and generates droplets and ice crystals
  * Interactive aerosol effects on both warm and cold clouds
* Microphysics predicts both number and mass concentration for ice and water
* precipitation in ice and snow is diagnosed
* Particle distributions treated as gamma functions
* Temperature of homogeneous freezing (but only for rain!) increased form -40C to -5C in released cam 5 to tune arctic surface flux
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


# Notes on gettelman 2010: [CAM_ICE]
* Supercooled rain freezes at -5ºC
* Sea ice does not treat supercooled rain, so caused anomalously low sea ice _in the coupled model_

# Notes on Impacts of representing heterogenous distribution of cloud liquid and ice on phase parititioning of arctic mixed clouds with CAM5 [CAM_WBF]

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




# Notes on Sensitivity Study on the Influence of CLoud Microphysical Parameters on Mixed-Phase Cloud Thermodynamic Phase Partitioning in CAM5 [SENSITIVITY]
* Tuning process rarely takes into account thermodynamic partition in mixed phase clouds
* `$$-30^\circ C $$` 
* Supercooled cloud fraction: Supercooled water MR/ice MR
* CALIOP; dual wavelength 3 degree polarization lidar. 
* Part of A train constellation
* How to get SCF from CALIOP data?
  * Choi 2010 for more details
  * No mixed-phase cloud category
  * This section is badly written
* CAM5.1 COTS configuration underestimates SCF by 90% relative to obs.
* convective detrainment scheme found to be culpable 
  * Condensate detrained from convective parameerizations is separated into three regimes.
  * Warmer than -10C ratio of ice to total cloud condensate that was detrained vanishes
  * Between -10 and -40 Fdet is a is a linear function of temperature
  * Below -40 its all ice
* Meyers '92 scheme is replaced with DeMott 2015 scheme so it can 1) calculate IN from large dust aerosols and 2) 
* Immersion scheme turned off, Contact freezing and halley mossop schemes were not changed.
* Parameters modified:
  1) Fraction of dust particles that are treated as IN
  2) WBF ice crystal time scale
  3) WBF snowflake time scale
  4) Ice crystal fall speed
  5) Moist scavenging of aerosols in stratiform clouds 
  6) Moist scavenging of aerosols in convective clouds
* parameters picked due to author's expertise
* Storelvmo '08 (author of this paper) thinks subgrid heterogeneity in ice/water pockets key error in WBF parameterization
* Implicit perfect overlap between ice and SC water causes WBF to be maximally efficient
* Zhao 2013 good choice
* Calculate SCFs at -10±1C, -20±1C, -30±1C  using `$$ \frac{w_{\textrm{liquid}}}{w_{\textrm{liquid}}+w_{\textrm{ice}}}$$`.
* Only use cloud top measurements except in optically thin clouds (where CALIOP measurements are useful)
* GLM applied on 20º wide latitude bands globally.
* SCF score as avg(scf_model-ij) - avg(scf_model_obs_ij): i is ith 20º latitude band, j is isotherm (e.g. -10ºC, -20ºC, -30ºC as above).
* Cumulative score is the sum over i,j of these differences.
* Fig 4: Just spectacular
* At -20ºC there's a 15% contribution of WBF_S and WBF_I correlation, but the covvariance matrix is diagonally dominant.
* Autoconversion of ice to snow: only above 400 um
* Self-collection are parameterized, but colleciton ofdrolets by cloud ice is neglected in CAM5
* IN fraction also significant, particularly at highest isotherm (largest soure of ice crystals away from homogeneous freezing temps)
* (These were global analyses)
* Figure 5: Its _all_ WBF in the high latitudes, dude.
* Autoconversion: not a physical process. WTF is it?
* WBF_I majority of variance in mixed phase clouds. 

# Notes on Resilience of Persistent Arctic mixed-phase clouds [RESILIENCE]
* AMPC exist under synoptic subsidence
* Turbulence and cloud-scale upward air motion seem to be critical in maintaining mixed-phase clouds under weak synoptic-scale updrafts
* Strong enough updrafts -> supersaturated w.r.t. ice and water (both grow simultaneously)
* supercooled droplets lead to strong longwave radiative cooling (60K per day near cloud top whoa)
*   Can cause static instability! Condensation of droplets driven by this cooling
* Large scale advection creates frequent moisture inversions near cloud top
  * This is different from mixed-phase stratocumulus at lower latitudes (typically dry near cloud top)
* Entrainment of above-cloud air actually replenishes cloud water lost to (ice) precip
* Special: AMPCs can persist and be replenished even if not dynamically coupled to surface fluxes
* In case of dynamic coupling to surface:
  * Radiative cooling of SC water warms surface, cools atmosphere
  * Source of static instability: sensible heat flux and moisture drawn upwards into cloud
  * Ice concentration and large-water-drop concentration are correlated?
  * Ice often only forms after SC water is present (even if there is substantial ice-supersaturation before LW is present)
* Lmao complex system theory
* Two steady states of system:
  * Radiatively opaque, radiatively transparent
  * Bistable environment with two slow manifolds (PS/net surface LWR phase space)
* Buncha uncertainties:
  * synoptic vertical velocity: might determine two clusters
  * synoptic transport: maybe?
  * Two mixed-phase states have 30-40 W/m^2 difference in radiative impact (cloudy clouds are cloudier)
  * 