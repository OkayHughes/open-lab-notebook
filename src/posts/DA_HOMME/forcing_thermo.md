---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Running Held-suarez on a reduced-radius earth
layout: layouts/post.njk
---


<details>
  <summary>It sucks <code>atmos_cubed_sphere/model/fv_dynamics.F90</code></summary>
Last login: Sun May  5 14:05:13 on console
owhughes@s-mh-g440-m16 ~ % ssh owhughes@gl-login3.arc-ts.umich.edu
The authenticity of host 'gl-login3.arc-ts.umich.edu (141.211.192.40)' can't be established.
ED25519 key fingerprint is SHA256:9ho43xHw/aVo4q5AalH0XsKlWLKFSGuuw9lt3tCIYEs.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'gl-login3.arc-ts.umich.edu' (ED25519) to the list of known hosts.
************************************************************************
* By your use of these resources, you agree to abide by Proper Use of  *
* Information Resources, Information Technology, and Networks at the   *
* University of Michigan (SPG 601.07), in addition to all relevant     *
* state and federal laws. http://spg.umich.edu/policy/601.07           *
************************************************************************
* By using these resources, you certify that you are not presently     *
* located in a Comprehensively Embargoed Country (OFAC – Sanctions     *
* Programs) and that your use of the resources will comply in all      *
* respects with all applicable law, including U.S. export control      *
* laws and regulations, as well as with University policy.             *
* For questions contact the U-M Export Control Program at              *
* exportcontrols@umich.edu                                             *
************************************************************************

(owhughes@gl-login3.arc-ts.umich.edu) Password: 
(owhughes@gl-login3.arc-ts.umich.edu) Duo two-factor login for owhughes

Enter a passcode or select one of the following options:

 1. Duo Push to XXX-XXX-4995
 2. Phone call to XXX-XXX-4995
 3. SMS passcodes to XXX-XXX-4995

Passcode or option (1-3): 1
Success. Logging you in...
Last login: Thu Apr 25 16:17:42 2024 from 67.194.181.216

----------------------------------------------------------------------------
                   Advanced Research Computing

The home directory /home as well as the scratch directory /scratch
are intended for storing active data only.  Please do not use them for
long-term data storage.
Usage information, policies, news, please see: http://arc-ts.umich.edu
----------------------------------------------------------------------------

                        **** NOTICE ****
############################################################################
# ARC Summer 2024 Maintenance June 3-4                                     #
# No jobs will run past June 3rd, 7:00AM. See link for details:            #
# https://myumi.ch/Z3Q63/                                                  #
# Email arc-support@umich.edu if you have any questions                    #
############################################################################

Maintenance window scheduled to start at 07:00:00 (EDT) on Monday 06/03/2024.
Maintenance window begins in less than 29 days.
Recommended maximum wall time for new jobs is 14-00:00:00 (336:00:00).
Run 'maxwalltime' to see up to the minute information


(base) [owhughes@gl-login3 ~]$ 
(base) [owhughes@gl-login3 ~]$ 
(base) [owhughes@gl-login3 ~]$ 
(base) [owhughes@gl-login3 ~]$ 
(base) [owhughes@gl-login3 ~]$ tmux ls
error connecting to /tmp//tmux-99966334/default (No such file or directory)
(base) [owhughes@gl-login3 ~]$ tmux
[detached (from session 0)]
(base) [owhughes@gl-login3 ~]$ ls
cam_jun22.tar.gz  cam_vs_eam.diff.log  cesm        cesm_cases    cesm_src      climate_589_initial_ncl  def_files.tar.gz  development  e3sm_greatlakes_install  figures               find.log   initial     MPAS            PanoplyJ     perl5_old   regrid              slurm.conf  test.sh  w_in_mu_approx_1.ps
CAM_JUNE22        case_registry        cesm_2.1.3  CESM_GRIDS    CJ_class_ncl  containers               dependencies      diff.log     esmf                     final_project         for_peter  make_cases  nvvp_workspace  panoply.zip  postscript  screenshots         SlurpSE     tmp      w_in_no_rootfinding.ps
cam.tar.gz        cases                cesm2.1.3   cesm_install  classes       def_files                Desktop           E3SM         ExaMPM                   final_project.tar.gz  HOMME      miniconda3  ondemand        perl5        pv_panic    se_ext_mode.tar.gz  test        util     w_in_pnh_p_match.ps
(base) [owhughes@gl-login3 ~]$ module load ncview
c(base) [owhughes@gl-login3 ~]$ cd E3SM/installs/homme_deep/
(base) [owhughes@gl-login3 homme_deep]$ ls
CMakeCache.txt  CMakeDoxyfile.in  CMakeDoxygenDefaults.cmake  CMakeFiles  cmake_fortran_c_interface.h  cmake_install.cmake  cmake.sh  composef90  CTestTestfile.cmake  dcmip_tests  homme_git_sha.h  kokkos  Makefile  setup.sh  src  test  test_execs  tests  utils
(base) [owhughes@gl-login3 homme_deep]$ cd dcmip_tests/
(base) [owhughes@gl-login3 dcmip_tests]$ ls
CMakeFiles           CTestTestfile.cmake                      dcmip2012_test1.2_hadley_meridional_circulation  dcmip2012_test2.0_steady_state_with_orography  dcmip2012_test2.2_nh_mountain_waves_with_shear  dcmip2012_test4.1_baroclinic_instability  dcmip2016_test2_tropical_cyclone  Makefile
cmake_install.cmake  dcmip2012_test1.1_3d_deformational_flow  dcmip2012_test1.3_thin_clouds_over_orography     dcmip2012_test2.1_nh_mountain_waves_no_shear   dcmip2012_test3.1_nh_gravity_waves              dcmip2016_test1_baroclinic_wave           dcmip2016_test3_supercell
(base) [owhughes@gl-login3 dcmip_tests]$ cd dcmip2016_test1_baroclinic_wave/
(base) [owhughes@gl-login3 dcmip2016_test1_baroclinic_wave]$ ls
CMakeFiles  cmake_install.cmake  CTestTestfile.cmake  Makefile  preqx  theta-l  vcoord
(base) [owhughes@gl-login3 dcmip2016_test1_baroclinic_wave]$ cd theta-l/
(base) [owhughes@gl-login3 theta-l]$ ls
'\'               checkE-run2.nl        CTestTestfile.cmake   jobscript-gl.homme.sh   Makefile                     measurement_time.txt      namelist-deep_atm_ne60.nl    namelist-ne120.nl    namelist-ne4096.nl     namelist-r100.nl   oop.pdf                        slurm-7070549.out
 build.sh         checkE.sh             examine.py            jobscript-knl.sh        mass.out                     measurement_wmax.txt      namelist-deep_atm_small.nl   namelist-ne2048.nl   namelist-ne512.nl      namelist-r400.nl   parselogs.py                   tmp.txt
 checkE.ncl       CMakeFiles            HommeTime             jobscript-snl.sh        measurement_prect_rate.txt   movies                    namelist-deep_atm_test.nl    namelist-ne256.nl    namelist-r100-dry.nl   namelist-r50.nl    plot-baroclinicwave-init.ncl
 checkE-run1.nl   cmake_install.cmake   input.nl              log.txt                 measurement_psmin.txt        namelist-deep_atm_hs.nl   namelist-ne1024.nl           namelist-ne3072.nl   namelist-r100-h.nl     oof.txt            plot-lat-lon-TPLSPS.ncl
(base) [owhughes@gl-login3 theta-l]$ ls
'\'               checkE-run2.nl        CTestTestfile.cmake   jobscript-gl.homme.sh   Makefile                     measurement_time.txt      namelist-deep_atm_ne60.nl    namelist-ne120.nl    namelist-ne4096.nl     namelist-r100.nl   oop.pdf                        slurm-7070549.out
 build.sh         checkE.sh             examine.py            jobscript-knl.sh        mass.out                     measurement_wmax.txt      namelist-deep_atm_small.nl   namelist-ne2048.nl   namelist-ne512.nl      namelist-r400.nl   parselogs.py                   tmp.txt
 checkE.ncl       CMakeFiles            HommeTime             jobscript-snl.sh        measurement_prect_rate.txt   movies                    namelist-deep_atm_test.nl    namelist-ne256.nl    namelist-r100-dry.nl   namelist-r50.nl    plot-baroclinicwave-init.ncl
 checkE-run1.nl   cmake_install.cmake   input.nl              log.txt                 measurement_psmin.txt        namelist-deep_atm_hs.nl   namelist-ne1024.nl           namelist-ne3072.nl   namelist-r100-h.nl     oof.txt            plot-lat-lon-TPLSPS.ncl
(base) [owhughes@gl-login3 theta-l]$ vim jobscript-gl.homme.sh 
(base) [owhughes@gl-login3 theta-l]$ ncview movies/
6_day_run.nc         CMakeFiles/          cmake_install.cmake  CTestTestfile.cmake  held_suarez01.nc     Makefile             output_dir_test      without_root.nc      with_root.nc         
(base) [owhughes@gl-login3 theta-l]$ tmux ls
0: 1 windows (created Sun May  5 14:49:01 2024) [316x78]
(base) [owhughes@gl-login3 theta-l]$ tmux a -t 0
(base) [owhughes@gl-login3 theta-l]$ tmux ls
0: 1 windows (created Sun May  5 14:49:01 2024) [316x78]
(base) [owhughes@gl-login3 theta-l]$ tmux a -t 0
[detached (from session 0)]
(base) [owhughes@gl-login3 theta-l]$ ls
'\'               checkE-run2.nl        CTestTestfile.cmake   jobscript-gl.homme.sh   Makefile                     measurement_time.txt      namelist-deep_atm_ne60.nl    namelist-ne120.nl    namelist-ne4096.nl     namelist-r100.nl   oop.pdf                        slurm-7070549.out
 build.sh         checkE.sh             examine.py            jobscript-knl.sh        mass.out                     measurement_wmax.txt      namelist-deep_atm_small.nl   namelist-ne2048.nl   namelist-ne512.nl      namelist-r400.nl   parselogs.py                   tmp.txt
 checkE.ncl       CMakeFiles            HommeTime             jobscript-snl.sh        measurement_prect_rate.txt   movies                    namelist-deep_atm_test.nl    namelist-ne256.nl    namelist-r100-dry.nl   namelist-r50.nl    plot-baroclinicwave-init.ncl
 checkE-run1.nl   cmake_install.cmake   input.nl              log.txt                 measurement_psmin.txt        namelist-deep_atm_hs.nl   namelist-ne1024.nl           namelist-ne3072.nl   namelist-r100-h.nl     oof.txt            plot-lat-lon-TPLSPS.ncl
(base) [owhughes@gl-login3 theta-l]$ ls
'\'               checkE-run2.nl        CTestTestfile.cmake   jobscript-gl.homme.sh   Makefile                     measurement_time.txt      namelist-deep_atm_ne60.nl    namelist-ne120.nl    namelist-ne4096.nl     namelist-r100.nl   oop.pdf                        slurm-7070549.out
 build.sh         checkE.sh             examine.py            jobscript-knl.sh        mass.out                     measurement_wmax.txt      namelist-deep_atm_small.nl   namelist-ne2048.nl   namelist-ne512.nl      namelist-r400.nl   parselogs.py                   tmp.txt
 checkE.ncl       CMakeFiles            HommeTime             jobscript-snl.sh        measurement_prect_rate.txt   movies                    namelist-deep_atm_test.nl    namelist-ne256.nl    namelist-r100-dry.nl   namelist-r50.nl    plot-baroclinicwave-init.ncl
 checkE-run1.nl   cmake_install.cmake   input.nl              log.txt                 measurement_psmin.txt        namelist-deep_atm_hs.nl   namelist-ne1024.nl           namelist-ne3072.nl   namelist-r100-h.nl     oof.txt            plot-lat-lon-TPLSPS.ncl
(base) [owhughes@gl-login3 theta-l]$ ncview movies/held_suarez01.nc 
Ncview 2.1.8 David W. Pierce  8 March 2017
http://meteora.ucsd.edu:80/~pierce/ncview_home_page.html
Copyright (C) 1993 through 2015, David W. Pierce
Ncview comes with ABSOLUTELY NO WARRANTY; for details type `ncview -w'.
This is free software licensed under the Gnu General Public License version 3; type `ncview -c' for redistribution details.

Error: Can't open display: 
(base) [owhughes@gl-login3 theta-l]$ logout
Connection to gl-login3.arc-ts.umich.edu closed.
owhughes@s-mh-g440-m16 ~ % ssh -Y owhughes@gl-login3.arc-ts.umich.edu
************************************************************************
* By your use of these resources, you agree to abide by Proper Use of  *
* Information Resources, Information Technology, and Networks at the   *
* University of Michigan (SPG 601.07), in addition to all relevant     *
* state and federal laws. http://spg.umich.edu/policy/601.07           *
************************************************************************
* By using these resources, you certify that you are not presently     *
* located in a Comprehensively Embargoed Country (OFAC – Sanctions     *
* Programs) and that your use of the resources will comply in all      *
* respects with all applicable law, including U.S. export control      *
* laws and regulations, as well as with University policy.             *
* For questions contact the U-M Export Control Program at              *
* exportcontrols@umich.edu                                             *
************************************************************************

(owhughes@gl-login3.arc-ts.umich.edu) Password: 
(owhughes@gl-login3.arc-ts.umich.edu) Duo two-factor login for owhughes

Enter a passcode or select one of the following options:

 1. Duo Push to XXX-XXX-4995
 2. Phone call to XXX-XXX-4995
 3. SMS passcodes to XXX-XXX-4995

Passcode or option (1-3): 1
Success. Logging you in...
Last login: Sun May  5 14:18:29 2024 from 67.194.181.122

----------------------------------------------------------------------------
                   Advanced Research Computing

The home directory /home as well as the scratch directory /scratch
are intended for storing active data only.  Please do not use them for
long-term data storage.
Usage information, policies, news, please see: http://arc-ts.umich.edu
----------------------------------------------------------------------------

                        **** NOTICE ****
############################################################################
# ARC Summer 2024 Maintenance June 3-4                                     #
# No jobs will run past June 3rd, 7:00AM. See link for details:            #
# https://myumi.ch/Z3Q63/                                                  #
# Email arc-support@umich.edu if you have any questions                    #
############################################################################

Maintenance window scheduled to start at 07:00:00 (EDT) on Monday 06/03/2024.
Maintenance window begins in less than 29 days.
Recommended maximum wall time for new jobs is 14-00:00:00 (336:00:00).
Run 'maxwalltime' to see up to the minute information




(base) [owhughes@gl-login3 ~]$ 
(base) [owhughes@gl-login3 ~]$ 
(base) [owhughes@gl-login3 ~]$ tmux ls
0: 1 windows (created Sun May  5 14:49:01 2024) [316x78]
(base) [owhughes@gl-login3 ~]$ tmux a -t 0
[detached (from session 0)]
(base) [owhughes@gl-login3 ~]$ ls
cam_jun22.tar.gz  cam_vs_eam.diff.log  cesm        cesm_cases    cesm_src      climate_589_initial_ncl  def_files.tar.gz  development  e3sm_greatlakes_install  figures               find.log   initial     MPAS            PanoplyJ     perl5_old   regrid              slurm.conf  test.sh  w_in_mu_approx_1.ps
CAM_JUNE22        case_registry        cesm_2.1.3  CESM_GRIDS    CJ_class_ncl  containers               dependencies      diff.log     esmf                     final_project         for_peter  make_cases  nvvp_workspace  panoply.zip  postscript  screenshots         SlurpSE     tmp      w_in_no_rootfinding.ps
cam.tar.gz        cases                cesm2.1.3   cesm_install  classes       def_files                Desktop           E3SM         ExaMPM                   final_project.tar.gz  HOMME      miniconda3  ondemand        perl5        pv_panic    se_ext_mode.tar.gz  test        util     w_in_pnh_p_match.ps
(base) [owhughes@gl-login3 ~]$ cd E3SM/installs/homme_deep/dcmip_tests/dcmip2016_test1_baroclinic_wave/
(base) [owhughes@gl-login3 dcmip2016_test1_baroclinic_wave]$ ls
CMakeFiles  cmake_install.cmake  CTestTestfile.cmake  Makefile  preqx  theta-l  vcoord
(base) [owhughes@gl-login3 dcmip2016_test1_baroclinic_wave]$ cd theta-l/
(base) [owhughes@gl-login3 theta-l]$ ncview movies/held_suarez01.nc 
-bash: ncview: command not found
(base) [owhughes@gl-login3 theta-l]$ module load ncview
(base) [owhughes@gl-login3 theta-l]$ cd theta-l/
-bash: cd: theta-l/: No such file or directory
(base) [owhughes@gl-login3 theta-l]$ ncview movies/held_suarez01.nc 
Ncview 2.1.8 David W. Pierce  8 March 2017
http://meteora.ucsd.edu:80/~pierce/ncview_home_page.html
Copyright (C) 1993 through 2015, David W. Pierce
Ncview comes with ABSOLUTELY NO WARRANTY; for details type `ncview -w'.
This is free software licensed under the Gnu General Public License version 3; type `ncview -c' for redistribution details.

Note: udunits: unknown units for lev: "level"
calculating min and maxes for u.
XIO:  fatal IO error 11 (Resource temporarily unavailable) on X server "localhost:20.0"
      after 774 requests (774 known processed) with 0 events remaining.
(base) [owhughes@gl-login3 theta-l]$ tmux a -t 0
[detached (from session 0)]
(base) [owhughes@gl-login3 theta-l]$ ncview movies/held_suarez01.nc 
Ncview 2.1.8 David W. Pierce  8 March 2017
http://meteora.ucsd.edu:80/~pierce/ncview_home_page.html
Copyright (C) 1993 through 2015, David W. Pierce
Ncview comes with ABSOLUTELY NO WARRANTY; for details type `ncview -w'.
This is free software licensed under the Gnu General Public License version 3; type `ncview -c' for redistribution details.

Note: udunits: unknown units for lev: "level"
calculating min and maxes for v...
calculating min and maxes for T...
XIO:  fatal IO error 11 (Resource temporarily unavailable) on X server "localhost:20.0"
      after 1605 requests (1605 known processed) with 0 events remaining.
(base) [owhughes@gl-login3 theta-l]$ tmux a -t 0
[detached (from session 0)]
(base) [owhughes@gl-login3 theta-l]$ ncview movies/held_suarez01.nc 
Ncview 2.1.8 David W. Pierce  8 March 2017
http://meteora.ucsd.edu:80/~pierce/ncview_home_page.html
Copyright (C) 1993 through 2015, David W. Pierce
Ncview comes with ABSOLUTELY NO WARRANTY; for details type `ncview -w'.
This is free software licensed under the Gnu General Public License version 3; type `ncview -c' for redistribution details.

Note: udunits: unknown units for lev: "level"
calculating min and maxes for v...
calculating min and maxes for T...
^C
(base) [owhughes@gl-login3 theta-l]$ 
(base) [owhughes@gl-login3 theta-l]$ tmux a -t 0
[detached (from session 0)]
(base) [owhughes@gl-login3 theta-l]$ ls
'\'               checkE-run2.nl        CTestTestfile.cmake   jobscript-gl.homme.sh   Makefile                     measurement_time.txt      namelist-deep_atm_ne60.nl    namelist-ne120.nl    namelist-ne4096.nl     namelist-r100.nl   oop.pdf                        slurm-7070549.out
 build.sh         checkE.sh             examine.py            jobscript-knl.sh        mass.out                     measurement_wmax.txt      namelist-deep_atm_small.nl   namelist-ne2048.nl   namelist-ne512.nl      namelist-r400.nl   parselogs.py                   tmp.txt
 checkE.ncl       CMakeFiles            HommeTime             jobscript-snl.sh        measurement_prect_rate.txt   movies                    namelist-deep_atm_test.nl    namelist-ne256.nl    namelist-r100-dry.nl   namelist-r50.nl    plot-baroclinicwave-init.ncl
 checkE-run1.nl   cmake_install.cmake   input.nl              log.txt                 measurement_psmin.txt        namelist-deep_atm_hs.nl   namelist-ne1024.nl           namelist-ne3072.nl   namelist-r100-h.nl     oof.txt            plot-lat-lon-TPLSPS.ncl
(base) [owhughes@gl-login3 theta-l]$ ls
'\'               checkE-run2.nl        CTestTestfile.cmake   jobscript-gl.homme.sh   Makefile                     measurement_time.txt      namelist-deep_atm_ne60.nl    namelist-ne120.nl    namelist-ne4096.nl     namelist-r100.nl   oop.pdf                        slurm-7070549.out
 build.sh         checkE.sh             examine.py            jobscript-knl.sh        mass.out                     measurement_wmax.txt      namelist-deep_atm_small.nl   namelist-ne2048.nl   namelist-ne512.nl      namelist-r400.nl   parselogs.py                   tmp.txt
 checkE.ncl       CMakeFiles            HommeTime             jobscript-snl.sh        measurement_prect_rate.txt   movies                    namelist-deep_atm_test.nl    namelist-ne256.nl    namelist-r100-dry.nl   namelist-r50.nl    plot-baroclinicwave-init.ncl
 checkE-run1.nl   cmake_install.cmake   input.nl              log.txt                 measurement_psmin.txt        namelist-deep_atm_hs.nl   namelist-ne1024.nl           namelist-ne3072.nl   namelist-r100-h.nl     oof.txt            plot-lat-lon-TPLSPS.ncl
(base) [owhughes@gl-login3 theta-l]$ ncview movies/held_suarez01.nc 
Ncview 2.1.8 David W. Pierce  8 March 2017
http://meteora.ucsd.edu:80/~pierce/ncview_home_page.html
Copyright (C) 1993 through 2015, David W. Pierce
Ncview comes with ABSOLUTELY NO WARRANTY; for details type `ncview -w'.
This is free software licensed under the Gnu General Public License version 3; type `ncview -c' for redistribution details.

Note: udunits: unknown units for lev: "level"
calculating min and maxes for v...
calculating min and maxes for T...
XIO:  fatal IO error 11 (Resource temporarily unavailable) on X server "localhost:20.0"
      after 1374 requests (1371 known processed) with 0 events remaining.
(base) [owhughes@gl-login3 theta-l]$ tmux a -t 0
[detached (from session 0)]
(base) [owhughes@gl-login3 theta-l]$ ls
'\'           checkE-run1.nl   cmake_install.cmake   input.nl                log.txt                      measurement_psmin.txt   namelist-deep_atm_hs.nl      namelist-ne1024.nl   namelist-ne3072.nl     namelist-r100-h.nl   oof.txt                        plot-lat-lon-TPLSPS.ncl
 asdf.txt     checkE-run2.nl   CTestTestfile.cmake   jobscript-gl.homme.sh   Makefile                     measurement_time.txt    namelist-deep_atm_ne60.nl    namelist-ne120.nl    namelist-ne4096.nl     namelist-r100.nl     oop.pdf                        slurm-7070549.out
 build.sh     checkE.sh        examine.py            jobscript-knl.sh        mass.out                     measurement_wmax.txt    namelist-deep_atm_small.nl   namelist-ne2048.nl   namelist-ne512.nl      namelist-r400.nl     parselogs.py                   tmp.txt
 checkE.ncl   CMakeFiles       HommeTime             jobscript-snl.sh        measurement_prect_rate.txt   movies                  namelist-deep_atm_test.nl    namelist-ne256.nl    namelist-r100-dry.nl   namelist-r50.nl      plot-baroclinicwave-init.ncl
(base) [owhughes@gl-login3 theta-l]$ cd
(base) [owhughes@gl-login3 ~]$ ls
ccam_jun22.tar.gz  cam_vs_eam.diff.log  cesm        cesm_cases    cesm_src      climate_589_initial_ncl  def_files.tar.gz  development  e3sm_greatlakes_install  figures               find.log   initial     MPAS            PanoplyJ     perl5_old   regrid              slurm.conf  test.sh  w_in_mu_approx_1.ps
CAM_JUNE22        case_registry        cesm_2.1.3  CESM_GRIDS    CJ_class_ncl  containers               dependencies      diff.log     esmf                     final_project         for_peter  make_cases  nvvp_workspace  panoply.zip  postscript  screenshots         SlurpSE     tmp      w_in_no_rootfinding.ps
cam.tar.gz        cases                cesm2.1.3   cesm_install  classes       def_files                Desktop           E3SM         ExaMPM                   final_project.tar.gz  HOMME      miniconda3  ondemand        perl5        pv_panic    se_ext_mode.tar.gz  test        util     w_in_pnh_p_match.ps
(base) [owhughes@gl-login3 ~]$ cd E3SM/
(base) [owhughes@gl-login3 E3SM]$ ls
cime.e3sm.singularity  CLDERA-E3SM  cldera.tar.gz  cmake.homme.sh  DA_HOMME_E3SM  e3sm.sif  installs  jobscript-gl.homme.sh  old_DA_HOMME  SA_HOMME_E3SM  S_case  scripts  X_case
(base) [owhughes@gl-login3 E3SM]$ cd DA_HOMME_E3SM/
(base) [owhughes@gl-login3 DA_HOMME_E3SM]$ ls
AUTHORS  cime  cime_config  CITATION.cff  codemeta.json  components  CONTRIBUTING.md  driver-mct  driver-moab  externals  LICENSE  README.md  run_e3sm.template.sh  share
(base) [owhughes@gl-login3 DA_HOMME_E3SM]$ ls
AUTHORS  cime  cime_config  CITATION.cff  codemeta.json  components  CONTRIBUTING.md  driver-mct  driver-moab  externals  LICENSE  README.md  run_e3sm.template.sh  share
(base) [owhughes@gl-login3 DA_HOMME_E3SM]$ ls
AUTHORS  cime  cime_config  CITATION.cff  codemeta.json  components  CONTRIBUTING.md  driver-mct  driver-moab  externals  LICENSE  README.md  run_e3sm.template.sh  share
(base) [owhughes@gl-login3 DA_HOMME_E3SM]$ cd components/
(base) [owhughes@gl-login3 components]$ ls
cice  cmake  CMakeLists.txt  data_comps  eam  eamxx  elm  homme  mosart  mpas-albany-landice  mpas-framework  mpas-ocean  mpas-seaice  stub_comps  ww3  xcpl_comps
(base) [owhughes@gl-login3 components]$ cd homme/
(base) [owhughes@gl-login3 homme]$ ls
cmake  CMakeLists.txt  compile_scripts  dcmip_tests  README  README.cmake  REGRESSION_TESTS  src  SVN_EXTERNAL_DIRECTORIES  test  test_execs  utils
(base) [owhughes@gl-login3 homme]$ cd src/
(base) [owhughes@gl-login3 src]$ ls
arkode             common_movie_mod.F90  implicit_mod.F90            linear_algebra_mod.F90  precon_mod.F90       preqx_acc     prim_main.F90         rebind.c           restart_io_mod.F90  surfaces_mod.F90  test_mod.F90  theta-l_kokkos         tool
checksum_mod.F90   derived_type_mod.F90  interp_movie_mod.F90        netcdf_io_mod.F90       precon_type_mod.F90  preqx_kokkos  prim_movie_mod.F90    repro_sum_mod.F90  r_hat.grep.log      sweqx             test_src      theta_restart_mod.F90  zoltan
common_io_mod.F90  eos_todo.diff.log     interpolate_driver_mod.F90  pio_io_mod.F90          preqx                prim          prim_restart_mod.F90  repro_sum_x86.c    share               swim              theta-l       todo.txt
(base) [owhughes@gl-login3 src]$ cd theta-l
(base) [owhughes@gl-login3 theta-l]$ ls
CMakeLists.txt  config.h.cmake.in  element_state.F90  prim_driver_mod.F90  share
(base) [owhughes@gl-login3 theta-l]$ cd share/
(base) [owhughes@gl-login3 share]$ ls
advance.diff.log  bndry_mod.F90  derivative_mod.F90  edge_mod.F90  element_ops.F90  eos.F90  imex_mod.F90  model_init_mod.F90  prim_advance_mod.F90  prim_advection_mod.F90  prim_state_mod.F90  vertremap_mod.F90  viscosity_mod.F90  viscosity_theta.F90
(base) [owhughes@gl-login3 share]$ ls
advance.diff.log  bndry_mod.F90  derivative_mod.F90  edge_mod.F90  element_ops.F90  eos.F90  imex_mod.F90  model_init_mod.F90  prim_advance_mod.F90  prim_advection_mod.F90  prim_state_mod.F90  vertremap_mod.F90  viscosity_mod.F90  viscosity_theta.F90
(base) [owhughes@gl-login3 share]$ ls
advance.diff.log  bndry_mod.F90  derivative_mod.F90  edge_mod.F90  element_ops.F90  eos.F90  imex_mod.F90  model_init_mod.F90  prim_advance_mod.F90  prim_advection_mod.F90  prim_state_mod.F90  vertremap_mod.F90  viscosity_mod.F90  viscosity_theta.F90
(base) [owhughes@gl-login3 share]$ vim element_ops.F90 
(base) [owhughes@gl-login3 share]$ tmux ls
0: 1 windows (created Sun May  5 14:49:01 2024) [316x78]
(base) [owhughes@gl-login3 share]$ tmux a -t 0
[detached (from session 0)]
(base) [owhughes@gl-login3 share]$ ls
advance.diff.log  bndry_mod.F90  derivative_mod.F90  edge_mod.F90  element_ops.F90  eos.F90  imex_mod.F90  model_init_mod.F90  prim_advance_mod.F90  prim_advection_mod.F90  prim_state_mod.F90  vertremap_mod.F90  viscosity_mod.F90  viscosity_theta.F90
(base) [owhughes@gl-login3 share]$ ls
advance.diff.log  bndry_mod.F90  derivative_mod.F90  edge_mod.F90  element_ops.F90  eos.F90  imex_mod.F90  model_init_mod.F90  prim_advance_mod.F90  prim_advection_mod.F90  prim_state_mod.F90  vertremap_mod.F90  viscosity_mod.F90  viscosity_theta.F90
(base) [owhughes@gl-login3 share]$ vim ../share/
advance.diff.log        derivative_mod.F90      element_ops.F90         imex_mod.F90            prim_advance_mod.F90    prim_state_mod.F90      viscosity_mod.F90       
bndry_mod.F90           edge_mod.F90            eos.F90                 model_init_mod.F90      prim_advection_mod.F90  vertremap_mod.F90       viscosity_theta.F90     
(base) [owhughes@gl-login3 share]$ vim ../share/prim_
prim_advance_mod.F90    prim_advection_mod.F90  prim_state_mod.F90      
(base) [owhughes@gl-login3 share]$ vim ../share/
advance.diff.log        derivative_mod.F90      element_ops.F90         imex_mod.F90            prim_advance_mod.F90    prim_state_mod.F90      viscosity_mod.F90       
bndry_mod.F90           edge_mod.F90            eos.F90                 model_init_mod.F90      prim_advection_mod.F90  vertremap_mod.F90       viscosity_theta.F90     
(base) [owhughes@gl-login3 share]$ vim ../../share/
bndry_mod_base.F90          coordinate_systems_mod.F90  dof_mod.F90                 gllfvremap_mod.F90          interpolate_mod.F90         metis_mod.F90               physics_mod.F90             .prim_driver_base.F90.swp   schedtype_mod.F90           thread_mod.F90              
cg_mod.F90                  cube_mod.F90                domain_mod.F90              gllfvremap_util_mod.F90     kinds.F90                   namelist_mod.F90            planar_mesh_mod.F90         prim_implicit_mod.F90       schedule_mod.F90            time_mod.F90                
compose/                    cxx/                        edge_mod_base.F90           global_norms_mod.F90        ll_mod.F90                  omp_config.h                planar_mod.F90              prim_si_mod.F90             sl_advection.F90            unit_tests_mod.F90          
compose_mod.F90             deep_atm_ctrl_mod.F90       edgetype_mod.F90            gridgraph_mod.F90           mass_matrix_mod.F90         parallel_mod.F90            prim_advection_base.F90     quadrature_mod.F90          solver_mod.F90              vertremap_base.F90          
compose_test_mod.F90        derivative_mod_base.F90     element_mod.F90             hybrid_mod.F90              mesh_mod.F90                params_mod.F90              prim_derived_type_mod.F90   reduction_mod.F90           sort_mod.F90                viscosity_base.F90          
control_mod.F90             dimensions_mod.F90          geometry_mod.F90            hybvcoord_mod.F90           metagraph_mod.F90           physical_constants.F90      prim_driver_base.F90        scalable_grid_init_mod.F90  spacecurve_mod.F90          zoltan_mod.F90              
(base) [owhughes@gl-login3 share]$ tmux a -t 0
[detached (from session 0)]
(base) [owhughes@gl-login3 share]$ ls
advance.diff.log  bndry_mod.F90  derivative_mod.F90  edge_mod.F90  element_ops.F90  eos.F90  imex_mod.F90  model_init_mod.F90  prim_advance_mod.F90  prim_advection_mod.F90  prim_state_mod.F90  vertremap_mod.F90  viscosity_mod.F90  viscosity_theta.F90
(base) [owhughes@gl-login3 share]$ vim ../../share/prim_driver_base.F90 

</details>


<details> <summary>The hydrostatic pressure routine:</summary>
  !_____________________________________________________________________
  subroutine get_hydro_pressure(p,dp,hvcoord)
  !
  implicit none

  real (kind=real_kind), intent(out)  :: p(np,np,nlev)
  real (kind=real_kind), intent(in)   :: dp(np,np,nlev)
  type (hvcoord_t),     intent(in)    :: hvcoord                      ! hybrid vertical coordinate struct

  integer :: k
  real(kind=real_kind), dimension(np,np,nlevp) :: p_i 

  p_i(:,:,1)=hvcoord%hyai(1)*hvcoord%ps0
  do k=1,nlev  ! SCAN
     p_i(:,:,k+1)=p_i(:,:,k) + dp(:,:,k)
  enddo
#ifdef HOMMEXX_BFB_TESTING
  do k=1,nlev
     p(:,:,k) = (p_i(:,:,k+1)+p_i(:,:,k))/2
  enddo
#else
  do k=1,nlev
     p(:,:,k)=p_i(:,:,k) + dp(:,:,k)/2
  enddo
#endif


  end subroutine get_hydro_pressure
</details>