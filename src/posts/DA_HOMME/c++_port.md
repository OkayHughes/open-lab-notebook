---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Porting DA HOMME to C++
layout: layouts/post.njk
---

Fine grain todo:
* ~~Rework dirk calling interface so code compiles~~
* ~~verify eos does not pass~~
* Determine ColumnOps call to calculate phi_i 

Coarse-grained todo:
* Ensure unit tests failing for DA HOMME
* Identify other unit tests that may be helpful
* Get caar_ut unit test to pass (CAAR seems easier?)
* get dirk unit test to pass (dirk seems easier?)



## Important notes
  * During fortran Dirk routine, phi_i and dphi become desynced. 
  As such, I'm currently assuming that it's best to add 
  a scan to `compute_pnh_and_exner` in order to calculate phi_i. 



