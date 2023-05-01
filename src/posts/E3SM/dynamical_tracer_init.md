---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Adding PV and PT as dynamical tracers to E3SM
  parent: E3SM
layout: layouts/post.njk
---

Ok so PV and PT are non-zero at the end of `inidat,` which is contained in the EAM code.

However, at the time that `prim_init2` is called within the HOMME code, it has been zeroed out (based on log files that show min/max values).
## Where is `prim_init2` called?

In `eam/src/dynamics/se/dyn_comp.F90`


