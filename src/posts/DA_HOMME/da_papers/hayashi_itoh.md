---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Notes on papers
  key: Hayashi, Itoh
layout: layouts/post.njk
---

## Setup
* Linearize the QHE on an equatorial `$$\beta$$` plane with rayleigh dampiong of velocity (bizarrely, laplacian diffusion is retained)
* No base flow.


## Scale analysis:

* Time scale of 10 days. 
* Deep convective heating rate of 10K/day. No source given for where this comes from.
* Zonal wind is chosen to be 10 m/s
* Results aren't super relevant for identifying cases.


## Linear eigenproblem:
* Heating profile looks like  `$$$Q_a \cos\left(\frac{\pi y}{H_y}\right) \cos\left(\frac{\pi x}{H_x}\right)  \sin\left(\frac{\pi z}{z_h}\right) \exp\left(\frac{z}{2H}\right) \exp\left(-i\omega t \right) $$$` on `$$[-H_x/2, H_x/2] \times [-H_y/2,H_y/2] \times [0, z_h] $$`
* Reaches maximum at approx 9km.
* `$$Q_a$$` is 10 K/day.
* Constant lapse rate atmosphere for base state. No background wind.
* Relative differences of 10-20 percent (higher when `$$H_x/H_y = 2$$`).
* Phase speed of 50 days. Results are not sensitive to this.
  
## Explanation of what's happening:
* Strength of heating determines `$$\pder{w_{\textrm{deep}}}{y}$$`, inducing meridional tilting of planetary vorticity.
* Temperature structure is not coupled to this tilting. 

Takeaways:
  * Find places where diabatic heating and `$$\pder{w_{\textrm{deep}}}{y}$$` are tighly coupled vs instances where 
  there are other factors driving synoptic structure of vertical motion
  * 