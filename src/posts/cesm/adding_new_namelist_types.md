---
date: 2021-09-01
tags:
  - posts
  - regridding
eleventyNavigation:
  key: Adding new namelist options
  parent: Community Earth System Model lifehacks
layout: layouts/post.njk
---

<details>
<summary>Where analytic_ic_type appears in the code</summary>
```
./components/cam/bld/namelist_files/namelist_defaults_cam.xml:<analytic_ic_type                   > none </analytic_ic_type>
./components/cam/bld/namelist_files/namelist_defaults_cam.xml:<analytic_ic_type phys="adiabatic"  > held_suarez_1994 </analytic_ic_type>
./components/cam/bld/namelist_files/namelist_defaults_cam.xml:<analytic_ic_type phys="held_suarez"> held_suarez_1994 </analytic_ic_type>
./components/cam/bld/namelist_files/namelist_defaults_cam.xml:<analytic_ic_type phys="kessler"    > moist_baroclinic_wave_dcmip2016 </analytic_ic_type>
./components/cam/bld/namelist_files/namelist_definition.xml:<entry id="analytic_ic_type" type="char*80" category="dyn_test"
./components/cam/bld/build-namelist:    add_default($nl, 'analytic_ic_type');
./components/cam/src/dynamics/tests/inic_analytic.F90:  use inic_analytic_utils, only: analytic_ic_active, analytic_ic_type
./components/cam/src/dynamics/tests/inic_analytic.F90:    select case(trim(analytic_ic_type))
./components/cam/src/dynamics/tests/inic_analytic.F90:      call endrun(subname//': Unknown analytic_ic_type, "'//trim(analytic_ic_type)//'"')
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:  character(len=scheme_len), public, protected :: analytic_ic_type = 'none'
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:    analytic_ic_active = (trim(analytic_ic_type) /= 'none')
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:    namelist /analytic_ic_nl/ analytic_ic_type
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:      analytic_ic_type = shr_string_toLower(analytic_ic_type)
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:    call mpi_bcast(analytic_ic_type, len(analytic_ic_type), mpi_character, masterprocid, mpicom, ierr)
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:       select case(trim(analytic_ic_type))
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:          msg = subname//': ERROR: analytic_ic_type must be set'
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:          msg = subname//': ERROR: analytic_ic_type not recognized: '//trim(analytic_ic_type)
./components/cam/src/dynamics/tests/inic_analytic_utils.F90:    analytic_ic_type = 'none'
```
                                                                   
</details>