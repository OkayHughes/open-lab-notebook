---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Identifying problems with dycore
  parent: FV3 Dycore Posts
layout: layouts/post.njk
---

Let us test the following configurations / aspects that caused issues in the 2020 FV3 version as integrated in the CAM development branch used for the class (Jan. 2022):
*  Missing timing information after the job completes, even the setting of 
xmlchange SAVE_TIMING=TRUE
does not cure the problem. Other dycores have the same issue (dycore independent).
* Found by Anthony in class project 3: with FVC96 hord=5 (see the non-diffusive settings for FV3 in class project 3) the dry UMJS14 baroclinic wave blows up shortly after day 18 (in CAM development with original FV3) with default time steps and 6th order div damping (nord=2)
Anthony found that a switch to the more diffusive hord=6 setting cured the problem
also happens for moist bw with FV3C48 with hord=5
* FV3 fails to start from its own IC file (generated with inithist FV3C24L93 in /glade/scratch/cjablono/CAM_Jan22.FV3C24.L93.fhs94_RF_physics_ic_file/run )
This file might not exist any longer. The point is that I created an IC file for a Held-Suarez run via inithist, and was not able to start a fresh run (without the analytic_ic setting that HS has by default) that uses this file as the IC file. Runs failed at the initialization step.*
* fv3_kord_tm = 9 fails (mapping of potential temperature), does this work now?
* On Cheyenne: is this relevant?: no C24, C192, C384 meshes in  /glade/p/cesmdata/cseg/inputdata/share/meshes/
* default coupling frequency / time step stays constant, is (for FV3C24, C48, C96, C192): ATM_NCPL: 48 (double check)
* fv3_nord = 3 (default) is unstable for baroclinic wave, lots of grid imprinting, ultimately blows up (needs to be confirmed), affects both hord=5 and hord=6 as I recall
* With mountain-generated bw test: fv3_d_ext creates numerical noise at cubed-sphere interfaces in C96 d_ext=0.01, 0.015 and 0.02 tested (default is fv3_d_ect=0), C192L30 with d_ext=0.02 blows up
* does the new FV3 accept FV3 code changes in SourceMods/src.cam now? These were ignored in the 2020 version.
* FV3 aqua-planet: missing input files for L30 for all resolutions except C96 in /glade/p/cesmdata/cseg/inputdata/atm/cam/inic/fv3
* only L26 and L32 supported for all resolutions
* C48 default build namelist fails for the ocean
* /glade/u/home/cjablono/CAM_Jan22/components/cdeps/docn/cime_config/buildnml
and complains about the missing mesh file: /glade/p/cesmdata/cseg/inputdata/share/meshes/C48_181018_ESMFmesh.nc 
during the build of the ocean namelist file docn_in
The reason for the failure is that the name of the input mesh file changed to /glade/p/cesmdata/cseg/inputdata/share/meshes/C48_ESMFmesh_c20200824.nc
  * cured by CJ: 
  * user_nl_docn was changed to include the settings:
`model_maskfile = "/glade/p/cesmdata/cseg/inputdata/share/meshes/C48_ESMFmesh_c20200824.nc`
`model_meshfile = "/glade/p/cesmdata/cseg/inputdata/share/meshes/C48_ESMFmesh_c20200824.nc"`
and the ocean namelist docn_in was built correctly.
  * However, the file in the scratch directory 
nuopc.runconfig  still lists the wrong mesh files for the entries `mesh_atm, mesh_ice, mesh_ocn`
despite the `user_nl_docn` changes (point a)
  * cured by: manually specify the mesh file settings in the case directory `xmlchange ATM_DOMAIN_MESH=/glade/p/cesmdata/cseg/inputdata/share/meshes/C48_ESMFmesh_c20200824.nc`
  * `xmlchange ICE_DOMAIN_MESH=/glade/p/cesmdata/cseg/inputdata/share/meshes/C48_ESMFmesh_c20200824.nc`
  * `xmlchange OCN_DOMAIN_MESH=/glade/p/cesmdata/cseg/inputdata/share/meshes/C48_ESMFmesh_c20200824.nc`
  * This corrects the nuopc.runconfig in the scratch directory and also leads to a successful case.submit
* C384 did not run (memory problem?) Does this run now for the UMJS14 test?
* FV3 slab ocean: fails due to missing QFLUX files on Cheyenne
* RCE configurations fails (all dycores)








