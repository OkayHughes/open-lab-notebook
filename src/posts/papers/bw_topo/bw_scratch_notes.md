---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: BW Scratch notes
  parent: Baroclinic Wave Test Case with Topography
layout: layouts/post.njk
---

## Notes on precipitation histograms:
Interesting paper [https://journals.ametsoc.org/view/journals/hydr/18/6/jhm-d-16-0209_1.xml](https://journals.ametsoc.org/view/journals/hydr/18/6/jhm-d-16-0209_1.xml)

Useful term: "Hydrograph"

Paper that uses gridpoint histograms to evaluate accuracy of prediction
at (I think) nominal 50km spacing [https://journals.ametsoc.org/view/journals/clim/16/22/1520-0442_2003_016_3841_tsooas_2.0.co_2.xml](Temporal–Spatial Scales of Observed and Simulated Precipitation in Central U.S. Climate)

- Todo: check whether validation paper references contain anything fruitful

Atmospheric river specific: [https://www.nature.com/articles/ngeo2894]


Precipitation intercomparison: [https://link.springer.com/article/10.1007/s00382-015-2959-5](A multimodel intercomparison of resolution effects on precipitation: simulations and theory)

2014 evaluation: [https://link.springer.com/article/10.1007/s10584-014-1117-0](Changes in extremes and hydroclimatic regimes in the CREMA ensemble projections)
(Contains mentions of some useful precipitation metrics

[https://journals.ametsoc.org/view/journals/clim/27/14/jcli-d-13-00320.1.xml#bib5](How Well Are the Distribution and Extreme Values of Daily Precipitation over North America Represented in the Community Climate System Model? A Comparison to Reanalysis, Satellite, and Gridded Station Data )


[https://journals.ametsoc.org/view/journals/clim/21/7/2007jcli1494.1.xml](On the Verification and Comparison of Extreme Rainfall Indices from Climate Models)


## Methodology:
* Using the area average interpretation of model intercomparison output, choose a nominal grid spacing most consistent with the coarsest grid spacing chosen (nominally 1 degree or so). 

* Remap by averaging across spatial scales (use area average assumption to deal with offsets in latlon grid) to coarse grid at each 6h output 


Question: What is treated as an IID sample? 