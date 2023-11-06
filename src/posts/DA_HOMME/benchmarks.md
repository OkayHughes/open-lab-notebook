---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Benchmarking the first functional checkpoint
layout: layouts/post.njk
---



* With constant gravity, and explicit time stepping (dt=1.0 seconds) an isothermal/constant-gamma atmosphere is 
stable. 
* With imex time stepping (dt=300, `tstep_type=7`), a constant-gamma atmosphere is stable (though w is of 
magnitude `1e-5` after 1200 seconds. `w` explodes near model top.)

* Enabling/disabling remapping does not affect stability for explicit time stepping.




