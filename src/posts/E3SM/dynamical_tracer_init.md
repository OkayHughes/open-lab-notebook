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

In `eam/src/dynamics/se/dyn_comp.F90`, it's called in the subroutine `dyn_init2`. Note that in idealized and adiabatic model configurations, `elem%Q` is set to zero.

## where is `dyn_init2` called?
In `am/src/control/startup_initialconds.F90,` the routine `initial_conds` calls `read_inidat`.


## summary of how to handle different cases:
in `eam/src/dynamics/se/restart_dynamics.F90`, `dyn_init2` is called. However, this seems to assume that all `Q` fields are read in from a restart file (reasonable). 
We don't actually have to change this! It's reasonable to assume that if you are running a restart file, it was initialized using the dynamics tracers.

It's also called in `eam/src/dynamics/se/inital.F90`


# Breadcrumb: where is PV_TRCR output?

Idea: don't have to change it at _output_ time. We can add/subtract value in EAM glue code before advection is called! 
Provisionally: modify `stepon_run3` in `eam/src/dynamics/se/stepon.F90`. Wrap the call to `dyn_run`. 
Current hypothesis: no matter what advection scheme you use, it's handled in calls to `prim_run_subcycle`
