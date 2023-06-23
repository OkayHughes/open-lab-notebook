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
All diffusion coefficients have been reduced to `$$6.3\cdot 10^{11} \textrm{ m}$$` using 
For fully explicit time stepping (`tstep_type=5`) the maximum


