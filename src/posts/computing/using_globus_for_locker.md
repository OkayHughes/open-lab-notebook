---
title: A quick to set up trash alias for bash
date: 2021-08-31
tags:
  - posts
  - slurm
  - scientific-computing
eleventyNavigation:
  key: Using Globus to access locker on GreatLakes
  parent: Scientific Computing
layout: layouts/post.njk
---

Following the link [https://app.globus.org/file-manager?origin_id=824d7a3d-c8dc-42eb-aa8f-c9cbf5101669]
and authorizing with the Umich SSO system gives you an interface that will
show you the `locker` filesystem. E.g. `/clasp-cjablono` exists in this interface, but is not visible on the greatlakes filesystem.

Once you find the file you are looking for, run `module load globus-cli` in a shell on a GreatLakes login node. 

An example of a command that copies a file from the locker system to `/scratch/cjablono-root/owhughes` is
```
globus transfer $GLOBUS_GREATLAKES:/nfs/locker/clasp-cjablono/owhughes/mountain_test_case_netcdf/dry_ne240.nc $GLOBUS_GREATLAKES:/scratch/cjablono_root/cjablono1/owhughes/dry_ne240.nc
```

If I recall correctly, you have to do some kind of authentication when you do this the first time. I think it was pretty self explanatory.
Christiane, you probably want to try a command that looks like 
```
globus transfer $GLOBUS_GREATLAKES:/nfs/locker/clasp-cjablono/owhughes/mountain_test_case_netcdf/dry_ne240.nc $GLOBUS_GREATLAKES:/scratch/cjablono_root/cjablono1/cjablono/dry_ne240.nc
```

Let me know how this goes. The major problem 







