---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Benchmarking the first checkpoint
layout: layouts/post.njk
---

In the `deep_atm_homme` branch of [my fork](https://github.com/OkayHughes/E3SM) of the E3SM repository
I have a commit that contains (theoretically) all of the changes necessary to 
have a deep atmosphere version of HOMME which satisfies the (continuum versions of) conservation equations
that we want to satisfy.

Currently I have a version of the deep atmosphere source code on Perlmutter stored in `~/DA_HOMME_E3SM`.
A reference shallow atmosphere version with commit `de075c76ac53caa` is stored in `~/SA_HOMME_E3SM`.
Respectively, their install directories are `~/installs/homme_deep_gravit` and `~/installs/homme_shallow`.


We use `ne30` resolution with `$$R_0=6.37\cdot10^5 \textrm{ m}$$` and `$$\Omega = 7.292\cdot 10^{-4} \textrm{ m} $$`.
All diffusion coefficients have been reduced to `$$6.3\cdot 10^{11} \textrm{ m}$$` using the scaling law `1e15(ne30/ne300)**3.2` listed in the code.
For fully explicit time stepping (`tstep_type=5`) the maximum time step is `$tstep=0.4$`. 
A 30 minute debug run on perlmutter with one full node can simulate 2.7 hours of motion.

I'm going to store `ne8` model runs on greatlakes, at `${nfs_home}/steady_state_deep_vs_shallow` with informative-ish names.


The current plan is as follows:
1) Quantify the ability of the SA and DA (in shallow mode) implementations to keep the UMJS14 steady state for 
a 2 hour simulation in explicit mode. These should be of comparable magnitude. PS should be an adequate metric for the moment.


2) Is the performance of the DA implementation comparable when cos coriolis terms are added

3) Is the performance of the DA implementation comparable when gravitational variation is added



Note:
Calculation of ps_v NEEDS to be backwards compatible with other models (otherwise there are
a BUNCH of code modifications that need to change).

Hypothesis:
  Fuckup in vertical remap is due to fact that phi_from_eos is used in NH code. Have I changed that yet?





