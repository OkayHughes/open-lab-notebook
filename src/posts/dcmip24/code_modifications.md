---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Code modifications for stratosphere
  parent: DCMIP 2024
layout: layouts/post.njk
---

The hybrid coordinates for the proposed gravity wave test case are located at `/glade/u/home/owhughes/homme_levels/hot_equal`.
88 levels corresponds to a maximum 800m grid spacing, 120 levels is 400m, and 207 levels is 200m.

The HOMME initialization script containing the modifications for the stratosphere is located at `/glade/u/home/owhughes/homme_levels/dcmip2016-baroclinic.F90`.
The three additional parameters are located at line 89.
`lapse_strat =-0.005d0 ` is the nominal lapse rate in the stratosphere, `strat_start = 20d3` is the geometric height at which the stratosphere starts,
and `T_weight = 0.5d0` is the weight factor for the Skamarock modification to the base state. Because we have been running shallow-atmosphere simulations, I have so far left it as `0.5`, which is the default version of the test case described in our paper.
Setting `T_weight=0.8d0` was used in the Deep-atmosphere MPAS paper. If we decide to simulate on a full-size earth, then this modification isn't needed at all!

The remaining changes in the file are:
* Line 189: `T0 =  (T_weight * T0E + (1.0d0 - T_weight) * T0P)` (Skamarock modification)
* Line 352: `T0 =  (T_weight * T0E +(1.0d0 - T_weight)* T0P)` (Skamarock modification)
* Line 476: `T0 = (T_weight * T0E + (1.0d0 - T_weight) * T0P)` (Skamarock modification)
* Line 478: `constAA = 1.d0 / lapse_strat` (Constant used in stratospheric temperature)
* Lines 485-511: Stratospheric temperature structure. 



If we are running with a full-sized earth, then the namelist I use in HOMME is
```
!
! namelist for dcmip2012 test2-0: steady-state atmosphere with orography
!_______________________________________________________________________
&ctl_nl
  nthreads          = 1
  partmethod        = 4                         ! mesh parition method: 4 = space filling curve
  topology          = "cube"                    ! mesh type: cubed sphere
  test_case         = "dcmip2016_test10"       ! test identifier
  theta_hydrostatic_mode = .false.
  ne                = 30                        ! number of elements per cube face
  qsize             = 6                         ! num tracer fields
! ndays             = 14                         ! num simulation days: 0 = use nmax steps
  nmax              = 2000
  statefreq         = 1                       ! number of steps between screen dumps
  restartfreq       = -1                        ! don't write restart files if < 0
  runtype           = 0                         ! 0 = new 
  rsplit            = 1                         ! unstable with desired rsplit=6 - why?
  qsplit            = 1
  integration       = 'explicit'                ! explicit time integration
  tstep_type        = 7                         ! 
  tstep             = 300                     ! largest timestep in seconds
!  tstep_type        = 5                         ! 
!  tstep             = 1                    ! largest timestep in seconds
  nu                = 1e15                      ! hyperviscosity 1e15*(ne30/ne3000)**3.2
  nu_s              = 1e15 
  nu_p              = 1e15 
  !nu_top            = 0
!  nu_top            =  2.5e5 !2.5e5/20
!  hypervis_subcycle_tom  = 6
  limiter_option      = 9  
  hypervis_order    = 2                         ! 2 = hyperviscosity
  hypervis_subcycle = 3                         ! 1 = no hyperviz subcycling
!  dcmip2_0_zetam    = 1e6
!  dcmip2_0_rm       = 0
!  omega             = 7.292D-3
!  rearth            = 6.371D4
!  omega             = 14.584D-4
!  rearth            = 3.1855D5
!omega             = 51.044D-4
!rearth            = 1.59275D5
  dcmip16_prec_type = -1    
    dcmip16_pbl_type  = -1 
/
&vert_nl
  !vform             = "ccm"                     ! vertical coordinate type "ccm"=hybrid pressure/terrain
!  vfile_mid     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/camm-30.ascii"
!  vfile_int     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/cami-30.ascii"
!  vfile_mid     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_88_m.ascii"
!   vfile_int     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_88_i.ascii"
!  vfile_mid     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_hot_88_m.ascii"
!   vfile_int     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_hot_88_i.ascii"
!  vfile_mid     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_120_m.ascii"
!  vfile_int     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_120_i.ascii"
!  vfile_mid     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_hot_120_m.ascii"
!  vfile_int     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_hot_120_i.ascii"
  vfile_mid     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_hot_207_m.ascii"
  vfile_int     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_hot_207_i.ascii"
!  vfile_mid     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_401_m.ascii"
!  vfile_int     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/z-equal_401_i.ascii"
!  vfile_mid     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/aspL60_mid.ascii"
!  vfile_int     = "/home/owhughes/E3SM/DA_HOMME_E3SM/components/homme/test/vcoord/aspL60_int.ascii"
/
&analysis_nl
  output_dir        = "./movies/one_mountain/"               ! destination dir for netcdf file
  output_timeunits  = 0,                        ! 1=days, 2=hours, 0=timesteps
  output_frequency  = 100,                       ! output every 12 hours
  output_varnames1  ='T','ps','u','v','w','geo','geo_i', 'geos','pnh',"Th","div"   ! variables to write to file
  interp_type       = 1                         ! 0=native grid, 1=bilinear
  output_type       ='pnetcdf'                   ! netcdf or pnetcdf
  num_io_procs      = 16         
  interp_nlat       = 181
  interp_nlon       = 360
  interp_gridtype   = 1
/
&prof_inparm
  profile_outpe_num   = 100
  profile_single_file	= .true.
/
```

