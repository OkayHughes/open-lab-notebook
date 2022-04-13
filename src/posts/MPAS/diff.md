---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Porting the deep atmosphere version of MPAS to CAM-MPAS
  parent: MPAS tutorials
layout: layouts/post.njk
---


```
diff -r CAM_Jan22_backup/src/dynamics/mpas/driver/cam_mpas_subdriver.F90 CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/driver/cam_mpas_subdriver.F90
330a331
>        type (field2DReal), pointer :: rTildeCell
387a389
>        call mpas_pool_get_subpool(domain_ptr % blocklist % structs, 'mesh', mesh)
391,392c393,396
< 
<        call mpas_pool_get_subpool(domain_ptr % blocklist % structs, 'mesh', mesh)
---
>     
>        !call mpas_pool_get_field(mesh, 'rTildeCell', rTildeCell)
>        !call mpas_dmpar_exch_halo_field(rTildeCell,(/1/))
>        !call mpas_pool_get_subpool(domain_ptr % blocklist % structs, 'mesh', mesh)
962a967,968
>        
>        type (field2DReal), pointer :: rTildeVertex, rTildeCell, rTildeEdge, rTildeLayer
964d969
< 
1034a1040,1043
>        call mpas_pool_get_field(meshPool, 'rTildeVertex', rTildeVertex)
>        call mpas_pool_get_field(meshPool, 'rTildeCell', rTildeCell)
>        call mpas_pool_get_field(meshPool, 'rTildeLayer', rTildeLayer)
>        call mpas_pool_get_field(meshPool, 'rTildeEdge', rTildeEdge)
1154a1164,1176
>        call MPAS_streamAddField(mesh_stream, rTildeCell, ierr=ierr)
>        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
>        call MPAS_streamAddField(mesh_stream, rTildeVertex, ierr=ierr)
>        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
>        call MPAS_streamAddField(mesh_stream, rTildeEdge, ierr=ierr)
>        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
>        call MPAS_streamAddField(mesh_stream, rTildeLayer, ierr=ierr)
>        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
> 
> 
> 
> 
> 
1232a1255,1260
>        
> 
>        call MPAS_dmpar_exch_halo_field(rTildeVertex)
>        call MPAS_dmpar_exch_halo_field(rTildeEdge)
>        call MPAS_dmpar_exch_halo_field(rTildeCell)
>        call MPAS_dmpar_exch_halo_field(rTildeLayer)
1341a1370
>        type (field2DReal), pointer :: rTildeVertex, rTildeCell, rTildeLayer, rTildeEdge
1449a1479,1484
>        call mpas_pool_get_field(allFields, 'rTildeVertex', rTildeVertex)
>        call mpas_pool_get_field(allFields, 'rTildeCell', rTildeCell)
>        call mpas_pool_get_field(allFields, 'rTildeLayer', rTildeLayer)
>        call mpas_pool_get_field(allFields, 'rTildeEdge', rTildeEdge)
>  
> 
1607a1643,1654
> 
>        call MPAS_streamAddField(restart_stream, rTildeCell, ierr=ierr)
>        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
>        call MPAS_streamAddField(restart_stream, rTildeVertex, ierr=ierr)
>        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
>        call MPAS_streamAddField(restart_stream, rTildeEdge, ierr=ierr)
>        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
>        call MPAS_streamAddField(restart_stream, rTildeLayer, ierr=ierr)
>        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
> 
> 
> 
1834a1882,1886
> 
>        call cam_mpas_update_halo('rTildeCell', endrun)
>        call cam_mpas_update_halo('rTildeVertex', endrun)
>        call cam_mpas_update_halo('rTildeLayer', endrun)
>        call cam_mpas_update_halo('rTildeEdge', endrun)
diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/core_atmosphere/diagnostics/pv_diagnostics.F CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/core_atmosphere/diagnostics/pv_diagnostics.F
20d19
< 
66d64
< 
142d139
< 
1244a1242,1243
>       ! deep
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell
1259a1259,1260
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
1264c1265,1266
<             rho(k,iCell) = rho_zz(k,iCell) * zz(k,iCell)
---
>             ! deep Eq. (13)
>             rho(k,iCell) = rho_zz(k,iCell) * zz(k,iCell) / rTildeCell(k,iCell)**2
diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/core_atmosphere/dynamics/mpas_atm_time_integration.F CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/core_atmosphere/dynamics/mpas_atm_time_integration.F
2020a2021,2022
>       ! deep
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeLayer
2027a2030,2031
>       logical, pointer :: config_weak_temperature_gradient
> 
2029a2034
>       call mpas_pool_get_config(configs, 'config_weak_temperature_gradient', config_weak_temperature_gradient)
2036a2042,2045
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
>       call mpas_pool_get_array(mesh, 'rTildeLayer', rTildeLayer)
> 
2062a2072
>                                    rTildeCell, rTildeLayer, & ! deep
2065c2075
<                                    cellSolveStart, cellSolveEnd, edgeSolveStart, edgeSolveEnd)
---
>                                    cellSolveStart, cellSolveEnd, edgeSolveStart, edgeSolveEnd, config_weak_temperature_gradient)
2072a2083
>                                    rTildeCell, rTildeLayer, & ! deep
2075c2086
<                                    cellSolveStart, cellSolveEnd, edgeSolveStart, edgeSolveEnd)
---
>                                    cellSolveStart, cellSolveEnd, edgeSolveStart, edgeSolveEnd, config_weak_temperature_gradient)
2103a2115,2117
>       ! deep
>       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
>       real (kind=RKIND), dimension(nVertLevels+1,nCells+1) :: rTildeLayer
2114c2128
< 
---
>       logical :: config_weak_temperature_gradient 
2125,2126c2139,2145
<       rcv = rgas/(cp-rgas)
<       c2 = cp*rcv
---
>       if (config_weak_temperature_gradient) then
>         rcv = 0.0_RKIND
>         c2 = rgas
>       else
>         rcv = rgas/(cp-rgas)
>         c2 = cp*rcv
>       end if
2137c2156,2157
<             cofwr(k,iCell) =.5*dtseps*gravity*(fzm(k)*zz(k,iCell)+fzp(k)*zz(k-1,iCell))
---
>            cofwr(k,iCell) =.5*dtseps*gravity*(fzm(k)*zz(k  ,iCell) &
>                                                  +fzp(k)*zz(k-1,iCell))
2142,2144c2162,2165
<             cofwz(k,iCell) = dtseps*c2*(fzm(k)*zz(k,iCell)+fzp(k)*zz(k-1,iCell))  &
<                  *rdzu(k)*cqw(k,iCell)*(fzm(k)*p (k,iCell)+fzp(k)*p (k-1,iCell))
<             coftz(k,iCell) = dtseps*   (fzm(k)*t (k,iCell)+fzp(k)*t (k-1,iCell))
---
>            cofwz(k,iCell) = dtseps*c2*(fzm(k)*zz(k,iCell)+fzp(k)*zz(k-1,iCell))  &
>                *rdzu(k)*cqw(k,iCell)*(fzm(k)*p (k,iCell)+fzp(k)*p (k-1,iCell))  &
>                *(rTildeLayer(k,iCell)**2)
>            coftz(k,iCell) = dtseps*   (fzm(k)*t (k,iCell)+fzp(k)*t (k-1,iCell))
2155,2157c2176,2178
< 
<             cofwt(k,iCell) = .5*dtseps*rcv*zz(k,iCell)*gravity*rb(k,iCell)/(1.+qtotal)  &
<                                 *p(k,iCell)/((rtb(k,iCell)+rt(k,iCell))*pb(k,iCell))
---
>             ! deep Eq. (31)
>             cofwt(k,iCell) = .5*dtseps*rcv*zz(k,iCell)*gravity/rTildeCell(k,iCell)**2*rb(k,iCell)/(1.+qtotal)  &
>                                         *p(k,iCell)/((rtb(k,iCell)+rt(k,iCell))*pb(k,iCell))
2412a2434,2436
>       ! deep
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeEdge
> 
2425a2450,2451
>       logical, pointer :: config_weak_temperature_gradient
> 
2482a2509,2512
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
>       call mpas_pool_get_array(mesh, 'rTildeEdge', rTildeEdge)
> 
2491a2522
>       call mpas_pool_get_config(configs, 'config_weak_temperature_gradient', config_weak_temperature_gradient)
2500,2501c2531,2533
<                                    specZoneMaskEdge, specZoneMaskCell &
<                                    )
---
>                                    rTildeCell, rTildeEdge, & ! deep
>                                    specZoneMaskEdge, specZoneMaskCell, &
>                                    config_weak_temperature_gradient)
2513,2514c2545,2547
<                                    specZoneMaskEdge, specZoneMaskCell &
<                                    )
---
>                                    rTildeCell, rTildeEdge, & ! deep
>                                    specZoneMaskEdge, specZoneMaskCell, &
>                                    config_weak_temperature_gradient)
2562a2596,2599
>       ! deep
>       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
>       real (kind=RKIND), dimension(nVertLevels,nEdges+1) :: rTildeEdge
> 
2584a2622,2624
> 
>       logical :: config_weak_temperature_gradient
> 
2591a2632
>       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
2593,2595c2634,2640
< 
<       rcv = rgas / (cp - rgas)
<       c2 = cp * rcv
---
>       if (config_weak_temperature_gradient) then
>         rcv = 0.0_RKIND
>         c2 = rgas
>       else
>         rcv = rgas / (cp - rgas)
>         c2 = cp * rcv
>       end if
2621,2624c2666,2683
<                  pgrad = ((rtheta_pp(k,cell2)-rtheta_pp(k,cell1))*invDcEdge(iEdge) )/(.5*(zz(k,cell2)+zz(k,cell1)))
<                  pgrad = cqu(k,iEdge)*0.5*c2*(exner(k,cell1)+exner(k,cell2))*pgrad
<                  pgrad = pgrad + 0.5*zxu(k,iEdge)*gravity*(rho_pp(k,cell1)+rho_pp(k,cell2))
<                  ru_p(k,iEdge) = ru_p(k,iEdge) + dts*(tend_ru(k,iEdge) - (1.0_RKIND - specZoneMaskEdge(iEdge))*pgrad)
---
>                 if (rTildeCell(k,cell1) > 1e-10) then
>                   rTildeTmp1 = rTildeCell(k,cell1)
>                 else
>                   rTildeTmp1 = 1.0
>                 end if
>                 if (rTildeCell(k,cell1) > 1e-10) then
>                   rTildeTmp2 = rTildeCell(k,cell2)
>                 else
>                   rTildeTmp2 = 1.0
>                 end if
>                 ! deep Eq. (19)
>                 pgrad = ((rtheta_pp(k,cell2)/rTildeTmp2**2-rtheta_pp(k,cell1)/rTildeTmp2**2)*invDcEdge(iEdge))&
>                         /(.5*(zz(k,cell2)+zz(k,cell1)))
>                 pgrad = cqu(k,iEdge)*0.5*c2*(exner(k,cell1)+exner(k,cell2))*pgrad
>                 ! deep Eq. (19) and (31)
>                 pgrad = pgrad + 0.5*zxu(k,iEdge)*gravity/rTildeEdge(k,iEdge)**2 & ! deep Eq. (31)
>                         *(rho_pp(k,cell1)/rTildeTmp1**2+rho_pp(k,cell2)/rTildeTmp2**2) ! deep Eq. (19)
>                 ru_p(k,iEdge) = ru_p(k,iEdge) + dts*(tend_ru(k,iEdge) - (1.0_RKIND - specZoneMaskEdge(iEdge))*pgrad)
2720,2728c2779,2787
<             rw_p(k,iCell) = rw_p(k,iCell) +  dts*tend_rw(k,iCell)                       &
<                        - cofwz(k,iCell)*((zz(k  ,iCell)*ts(k)                           &
<                                      -zz(k-1,iCell)*ts(k-1))                            &
<                                +resm*(zz(k  ,iCell)*rtheta_pp(k  ,iCell)                &
<                                      -zz(k-1,iCell)*rtheta_pp(k-1,iCell)))              &
<                        - cofwr(k,iCell)*((rs(k)+rs(k-1))                                &
<                                +resm*(rho_pp(k,iCell)+rho_pp(k-1,iCell)))               &
<                        + cofwt(k  ,iCell)*(ts(k  )+resm*rtheta_pp(k  ,iCell))           &
<                        + cofwt(k-1,iCell)*(ts(k-1)+resm*rtheta_pp(k-1,iCell))
---
>            ! deep Eq. (21).
>            rw_p(k,iCell) = rw_p(k,iCell) +  dts*tend_rw(k,iCell)                       &
>              - cofwz(k,iCell)*( zz(k  ,iCell)*(ts(k  )+resm*rtheta_pp(k,  iCell))/rTildeCell(k  ,iCell)**2   &
>              -zz(k-1,iCell)*(ts(k-1)+resm*rtheta_pp(k-1,iCell))/rTildeCell(k-1,iCell)**2 ) &
>               - cofwr(k,iCell)*((rs(k)/rTildeCell(k  ,iCell)**2+rs(k-1)/rTildeCell(k-1,iCell)**2)                                 &
>               +resm*(rho_pp(k,iCell)/rTildeCell(k  ,iCell)**2+rho_pp(k-1,iCell)/rTildeCell(k-1,iCell)**2))               &
>              + cofwt(k  ,iCell)*(ts(k  )+resm*rtheta_pp(k  ,iCell))           &
>               + cofwt(k-1,iCell)*(ts(k-1)+resm*rtheta_pp(k-1,iCell))
> 
2798a2858,2859
>       ! deep
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeEdge
2807a2869
>       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
2811a2874,2877
> 
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
>       call mpas_pool_get_array(mesh, 'rTildeEdge', rTildeEdge)
2837c2903,2912
< 
---
>               if (rTildeCell(k,cell1) > 1e-10) then
>                  rTildeTmp1 = rTildeCell(k,cell1)
>               else
>                  rTildeTmp1 = 1.0
>               end if
>               if (rTildeCell(k,cell2) > 1e-10) then
>                  rTildeTmp2 = rTildeCell(k,cell2)
>               else
>                 rTildeTmp2 = 1.0
>               end if
2845,2849c2920,2926
<                divCell1 = -(rtheta_pp(k,cell1)-rtheta_pp_old(k,cell1))
<                divCell2 = -(rtheta_pp(k,cell2)-rtheta_pp_old(k,cell2))
<                ru_p(k,iEdge) = ru_p(k,iEdge) + coef_divdamp*(divCell2-divCell1)*(1.0_RKIND - specZoneMaskEdge(iEdge)) &
<                                                       /(theta_m(k,cell1)+theta_m(k,cell2))
< 
---
>               ! deep Eq. (30)
>               divCell1 = -(rtheta_pp(k,cell1)-rtheta_pp_old(k,cell1))/rTildeTmp1**2
>               ! deep Eq. (30)
>               divCell2 = -(rtheta_pp(k,cell2)-rtheta_pp_old(k,cell2))/rTildeTmp2**2
>               ! deep Eq. (30)
>               ru_p(k,iEdge) = ru_p(k,iEdge) + coef_divdamp*(divCell2-divCell1)*(1.0_RKIND - specZoneMaskEdge(iEdge)) &
>                                 /(theta_m(k,cell1)+theta_m(k,cell2)) * rTildeEdge(k,iEdge)
2883a2961,2962
>       ! deep
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeEdge
2897a2977,2978
>       logical, pointer :: config_weak_temperature_gradient
> 
2953a3035,3037
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
>       call mpas_pool_get_array(mesh, 'rTildeEdge', rTildeEdge)
2954a3039
>       call mpas_pool_get_config(configs, 'config_weak_temperature_gradient', config_weak_temperature_gradient)
2960a3046
>                              rTildeCell, rTildeEdge, & ! deep
2963c3049
<                              cellSolveStart, cellSolveEnd, vertexSolveStart, vertexSolveEnd, edgeSolveStart, edgeSolveEnd)
---
>                              cellSolveStart, cellSolveEnd, vertexSolveStart, vertexSolveEnd, edgeSolveStart, edgeSolveEnd, config_weak_temperature_gradient)
2973a3060
>                              rTildeCell, rTildeEdge, & ! deep
2976c3063
<                              cellSolveStart, cellSolveEnd, vertexSolveStart, vertexSolveEnd, edgeSolveStart, edgeSolveEnd)
---
>                              cellSolveStart, cellSolveEnd, vertexSolveStart, vertexSolveEnd, edgeSolveStart, edgeSolveEnd, config_weak_temperature_gradient)
3017a3105,3107
>       ! deep
>       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
>       real (kind=RKIND), dimension(nVertLevels,nEdges+1) :: rTildeEdge
3035c3125
< 
---
>       logical :: config_weak_temperature_gradient
3040a3131
>       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
3042,3043c3133,3137
< 
<       rcv = rgas/(cp-rgas)
---
>       if (config_weak_temperature_gradient) then
>         rcv = 0.0_RKIND
>       else
>         rcv = rgas/(cp-rgas)
>       end if
3083,3089c3177,3187
<                rtheta_p(k,iCell) = rtheta_p_save(k,iCell) + rtheta_pp(k,iCell) &
<                                  - dt * rho_zz(k,iCell) * rt_diabatic_tend(k,iCell)
<                theta_m(k,iCell) = (rtheta_p(k,iCell) + rtheta_base(k,iCell))/rho_zz(k,iCell)
<                exner(k,iCell) = (zz(k,iCell)*(rgas/p0)*(rtheta_p(k,iCell)+rtheta_base(k,iCell)))**rcv
<                ! pressure_p is perturbation pressure
<                pressure_p(k,iCell) = zz(k,iCell) * rgas * (exner(k,iCell)*rtheta_p(k,iCell)+rtheta_base(k,iCell)  &
<                                                           * (exner(k,iCell)-exner_base(k,iCell)))
---
>               rtheta_p(k,iCell) = rtheta_p_save(k,iCell) + rtheta_pp(k,iCell) &
>                     - dt * rho_zz(k,iCell) * rt_diabatic_tend(k,iCell)
>               theta_m(k,iCell) = (rtheta_p(k,iCell) + rtheta_base(k,iCell))/rho_zz(k,iCell)
>               ! deep Eq. (23)
>               exner(k,iCell) = (zz(k,iCell)/rTildeCell(k,iCell)**2*(rgas/p0)*(rtheta_p(k,iCell)+rtheta_base(k,iCell)))**rcv
>               ! pressure_p is perturbation pressure
>               ! deep Eq. (23)
>               pressure_p(k,iCell) = zz(k,iCell) / rTildeCell(k,iCell)**2 * rgas & 
>                         *(exner(k,iCell)*rtheta_p(k,iCell) + rtheta_base(k,iCell)*(&
>                         exner(k,iCell)-exner_base(k,iCell)))
>               
3113a3212,3221
>             if (rTildeCell(k,cell1) > 1e-10) then
>                 rTildeTmp1 = rTildeCell(k,cell1)
>             else
>                 rTildeTmp1 = 1.0
>             end if
>             if (rTildeCell(k,cell2) > 1e-10) then
>                 rTildeTmp2 = rTildeCell(k,cell2)
>             else
>                 rTildeTmp2 = 1.0
>             end if
3116c3224,3225
<             u(k,iEdge) = 2.*ru(k,iEdge)/(rho_zz(k,cell1)+rho_zz(k,cell2))
---
>              u(k,iEdge) = 2.*ru(k,iEdge)/(rho_zz(k,cell1)/rTildeTmp1**2+rho_zz(k,cell2)/rTildeTmp2**2) &
>                          /rTildeEdge(k,iEdge)  
4346a4456,4458
>       ! deep
>       real(kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeLayer, rTildeEdge
> 
4359a4472,4474
>       logical, pointer :: config_deep_atmosphere
>       logical, pointer :: on_a_sphere
>       
4384a4500,4502
>       call mpas_pool_get_config(configs, 'config_deep_atmosphere', config_deep_atmosphere)
>       call mpas_pool_get_config(mesh, 'on_a_sphere', on_a_sphere)
> 
4492a4611,4615
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
>       call mpas_pool_get_array(mesh, 'rTildeLayer', rTildeLayer)
>       call mpas_pool_get_array(mesh, 'rTildeEdge', rTildeEdge)
> 
4515a4639
>          rTildeCell, rTildeLayer, rTildeEdge, & ! deep
4520a4645
>          config_deep_atmosphere, on_a_sphere, &
4542a4668
>       rTildeCell, rTildeLayer, rTildeEdge, & ! deep
4547a4674
>       config_deep_atmosphere, on_a_sphere, &
4643a4771,4772
>       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
> 
4653a4783,4787
>       ! deep
>       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
>       real (kind=RKIND), dimension(nVertLevels+1,nCells+1) :: rTildeLayer
>       real (kind=RKIND), dimension(nVertLevels,nEdges+1) :: rTildeEdge
> 
4669a4804,4805
>       logical, intent(in) :: config_deep_atmosphere
>       logical, intent(in) :: on_a_sphere
4691c4827
<       real (kind=RKIND) :: inv_r_earth
---
>       real (kind=RKIND) :: inv_r_earth, r_c
4716d4851
<       inv_r_earth = 1.0_RKIND / r_earth
4717a4853,4857
>       if (on_a_sphere) then   
>          inv_r_earth = 1.0_RKIND / r_earth 
>       else ! on a plane, r_earth -> infinity  
>          inv_r_earth = 0.0_RKIND
>       endif
4814c4954
<             dpdz(k,iCell) = -gravity*(rb(k,iCell)*(qtot(k,iCell)) + rr_save(k,iCell)*(1.+qtot(k,iCell)))
---
>             dpdz(k,iCell) = -(gravity/(rTildeCell(k,iCell)**2))*(rb(k,iCell)*(qtot(k,iCell)) + rr_save(k,iCell)*(1.+qtot(k,iCell)))
4835,4836c4975,4977
<                tend_u_euler(k,iEdge) =  - cqu(k,iEdge)*( (pp(k,cell2)-pp(k,cell1))*invDcEdge(iEdge)/(.5*(zz(k,cell2)+zz(k,cell1))) &
<                                               -0.5*zxu(k,iEdge)*(dpdz(k,cell1)+dpdz(k,cell2)) )
---
>               ! deep Eq. (17)
>               tend_u_euler(k,iEdge) =  - cqu(k,iEdge)*( (pp(k,cell2)-pp(k,cell1))*invDcEdge(iEdge)/(.5*(zz(k,cell2)+zz(k,cell1))) &
>                     -0.5*zxu(k,iEdge)*(dpdz(k,cell1)+dpdz(k,cell2))/rTildeEdge(k,iEdge)**2 )
4857c4998,4999
<             tend_u(k,iEdge) = - rdzw(k)*(wduz(k+1)-wduz(k)) !  first use of tend_u
---
>             ! deep Eq. (17) 
>             tend_u(k,iEdge) = - rdzw(k)*(wduz(k+1)-wduz(k))/rTildeEdge(k,iEdge) !  first use of tend_u
4878,4889c5020,5030
<             tend_u(k,iEdge) = tend_u(k,iEdge) + rho_edge(k,iEdge)* (q(k) - (ke(k,cell2) - ke(k,cell1))       &
<                                                                  * invDcEdge(iEdge))                            &
<                                              - u(k,iEdge)*0.5*(h_divergence(k,cell1)+h_divergence(k,cell2)) 
< #ifdef CURVATURE
<             ! curvature terms for the sphere
<             tend_u(k,iEdge) = tend_u(k,iEdge) &
<                              - 2.*omega*cos(angleEdge(iEdge))*cos(latEdge(iEdge))  &
<                                *rho_edge(k,iEdge)*.25*(w(k,cell1)+w(k+1,cell1)+w(k,cell2)+w(k+1,cell2))          & 
<                              - u(k,iEdge)*.25*(w(k+1,cell1)+w(k,cell1)+w(k,cell2)+w(k+1,cell2))                  &
<                                *rho_edge(k,iEdge) * inv_r_earth
< #endif
<          end do
---
>             ! deep Eq. (17).
>             if (rTildeCell(k,cell1) > 1e-10) then
>                 rTildeTmp1 = rTildeCell(k,cell1)
>             else
>                 rTildeTmp1 = 1.0
>             end if
>             if (rTildeCell(k,cell2) > 1e-10) then
>                 rTildeTmp2 = rTildeCell(k,cell2)
>             else
>                 rTildeTmp2 = 1.0
>             end if
4890a5032,5048
>             tend_u(k,iEdge) = tend_u(k,iEdge) + 0.5 * (rho_zz(k,cell1)/rTildeTmp1**2 &
>                 +rho_zz(k,cell2)/rTildeTmp2**2) &
>                 * (q(k) - (ke(k,cell2)-ke(k,cell1))*invDcEdge(iEdge)) &
>                 - u(k,iEdge)*0.5*(h_divergence(k,cell1)+h_divergence(k,cell2))/rTildeEdge(k,iEdge)
>          end do
>          ! curvature terms for the sphere
>          ! deep Eq. (17)
>          if (config_deep_atmosphere) then
>              do k=1,nVertLevels
>                  tend_u(k,iEdge) = tend_u(k,iEdge) + (&
>                             - 2.*omega*cos(angleEdge(iEdge))*cos(latEdge(iEdge)) &
>                              *.25*(w(k,cell1)+w(k+1,cell1)+w(k,cell2)+w(k+1,cell2)) &
>                             - u(k,iEdge)*.25*(w(k+1,cell1)+w(k,cell1)+w(k,cell2)+w(k+1,cell2))&
>                             * inv_r_earth / rTildeEdge(k,iEdge) ) &
>                             * rho_edge(k,iEdge) / rTildeEdge(k,iEdge)
>              end do
>          end if
5127,5140d5284
< #ifdef CURVATURE
<       do iCell = cellSolveStart, cellSolveEnd
< !DIR$ IVDEP
<          do k=2,nVertLevels
<             tend_w(k,iCell) = tend_w(k,iCell) + (rho_zz(k,iCell)*fzm(k)+rho_zz(k-1,iCell)*fzp(k))*          &
<                                       ( (fzm(k)*ur_cell(k,iCell)+fzp(k)*ur_cell(k-1,iCell))**2.             &
<                                        +(fzm(k)*vr_cell(k,iCell)+fzp(k)*vr_cell(k-1,iCell))**2. )/r_earth   &
<                                 + 2.*omega*cos(latCell(iCell))                                              &
<                                        *(fzm(k)*ur_cell(k,iCell)+fzp(k)*ur_cell(k-1,iCell))                 &
<                                        *(rho_zz(k,iCell)*fzm(k)+rho_zz(k-1,iCell)*fzp(k))
< 
<          end do
<       end do
< #endif
5242,5244c5386,5393
<               tend_w_euler(k,iCell) = tend_w_euler(k,iCell) - cqw(k,iCell)*(   &
<                                            rdzu(k)*(pp(k,iCell)-pp(k-1,iCell)) &
<                                          - (fzm(k)*dpdz(k,iCell) + fzp(k)*dpdz(k-1,iCell)) )  ! dpdz is the buoyancy term here.
---
>                   ! deep Eq. (20)
>                  !!  tend_w_euler(k,iCell) = tend_w_euler(k,iCell) - cqw(k,iCell)*(   &
>                  !!                               rdzu(k)*(pp(k,iCell)-pp(k-1,iCell)) &
>                  !!                             *(fzm(k)*rTildeCell(k,iCell)**2+fzp(k)*rTildeCell(k-1,iCell)**2) &
>                  !!                            - (fzm(k)*dpdz(k,iCell) + fzp(k)*dpdz(k-1,iCell)) )  ! dpdz is the buoyancy term here.
>                  tend_w_euler(k,iCell) = tend_w_euler(k,iCell) - cqw(k,iCell)*(   &
>                             rdzu(k)*(pp(k,iCell)-pp(k-1,iCell))*(rTildeLayer(k,iCell)**2) &
>                             - (fzm(k)*dpdz(k,iCell) + fzp(k)*dpdz(k-1,iCell)) )  ! dpdz is the buoyancy term here.
5248a5398,5414
>       if (config_deep_atmosphere) then
>          ! call mpas_log_write('deep_atmosphere NCT terms for w')
>          do iCell = cellSolveStart, cellSolveEnd
>            do k=2,nVertLevels
>              ! deep Eq. (20)
>               !! r_c = fzm(k)*rTildeCell(k,iCell)+fzp(k)*rTildeCell(k-1,iCell)
>              r_c = rTildeLayer(k,iCell)
>              tend_w(k,iCell) = tend_w(k,iCell) + (r_c**2)*(&
>                                 fzm(k)*( (ur_cell(k  ,iCell)**2 + vr_cell(k  ,iCell)**2)*inv_r_earth/r_c  &
>                                  + 2.*omega*cos(latCell(iCell))*ur_cell(k  ,iCell))&
>                                  *rho_zz(k  ,iCell)/rTildeCell(k  ,iCell)**2&
>                                  +fzp(k)*( (ur_cell(k-1,iCell)**2 + vr_cell(k-1,iCell)**2)*inv_r_earth/r_c  &
>                                   + 2.*omega*cos(latCell(iCell))*ur_cell(k-1,iCell))&
>                                   *rho_zz(k-1,iCell)/rTildeCell(k-1,iCell)**2 )
>            end do
>          end do
>       end if
5258,5259c5424,5425
<                                            (w(k+1,iCell)-w(k  ,iCell))*rdzw(k)                              &
<                                           -(w(k  ,iCell)-w(k-1,iCell))*rdzw(k-1) )*rdzu(k)
---
>                   (w(k+1,iCell)-w(k  ,iCell))*rdzw(k) &
>                    -(w(k  ,iCell)-w(k-1,iCell))*rdzw(k-1) )*rdzu(k)
5498a5665,5666
>       ! deep
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeEdge, rTildeVertex
5545a5714,5718
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
>       call mpas_pool_get_array(mesh, 'rTildeEdge', rTildeEdge)
>       call mpas_pool_get_array(mesh, 'rTildeVertex', rTildeVertex)
> 
5554a5728
>                rTildeCell, rTildeEdge, rTildeVertex, & ! deep
5566a5741
>             rTildeCell, rTildeEdge, rTildeVertex, & ! deep
5603a5779,5783
>     
>       ! deep
>       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
>       real (kind=RKIND), dimension(nVertLevels,nEdges+1) :: rTildeEdge
>       real (kind=RKIND), dimension(nVertLevels,nVertices+1) :: rTildeVertex
5664c5844,5845
<                vorticity(k,iVertex) = vorticity(k,iVertex) + s * u(k,iEdge)
---
>               ! deep Eq. (12)
>               vorticity(k,iVertex) = vorticity(k,iVertex) + s * u(k,iEdge) * rTildeEdge(k,iEdge)
5669c5850,5851
<             vorticity(k,iVertex) = vorticity(k,iVertex) * invAreaTriangle(iVertex)
---
>            ! deep Eq. (12)
>            vorticity(k,iVertex) = vorticity(k,iVertex) * invAreaTriangle(iVertex) / rTildeVertex(k,iVertex)**2
5684c5866,5867
<               divergence(k,iCell) = divergence(k,iCell) + s * u(k,iEdge)
---
>               ! deep Eq. (11)
>               divergence(k,iCell) = divergence(k,iCell) + s * u(k,iEdge) * rTildeEdge(k,iEdge)
5689c5872,5873
<             divergence(k,iCell) = divergence(k,iCell) * r
---
>            ! deep Eq. (11)
>            divergence(k,iCell) = divergence(k,iCell) * r / rTildeCell(k,iCell)**2
5879c6063
< 
---
>       use cam_logfile,         only: iulog
5915a6100,6105
>       
>       ! deep
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeEdge
>       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
> 
5918a6109
>       logical, pointer :: config_weak_temperature_gradient
5955a6147,6151
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
>       call mpas_pool_get_array(mesh, 'rTildeEdge', rTildeEdge)
>       call mpas_pool_get_config(configs, 'config_weak_temperature_gradient', config_weak_temperature_gradient)
> 
5957c6153,6157
<       rcv = rgas / (cp-rgas)
---
>       if (config_weak_temperature_gradient) then  
>         rcv = 0.0_RKIND
>       else 
>         rcv = rgas / (cp-rgas)
>       end if 
5963c6163,6165
<             rho_zz(k,iCell) = rho(k,iCell) / zz(k,iCell)
---
>             ! deep Eq. (13)
>             rho_zz(k,iCell) = rho(k,iCell) * rTildeCell(k,iCell)**2 / zz(k,iCell)
>             !write(iulog,*) "            k, cell1, rTildeCell",k, '    ', iCell, '         ', rTildeCell(k,iCell)**2
5973c6175,6188
<             ru(k,iEdge) = 0.5 * u(k,iEdge) * (rho_zz(k,cell1) + rho_zz(k,cell2))
---
>            ! deep Eq. (14)
>            if (rTildeCell(k,cell1) > 1e-10) then
>             rTildeTmp1 = rTildeCell(k,cell1)
>            else
>             rTildeTmp1 = 1.0_RKIND
>            end if
> 
>            if (rTildeCell(k,cell2) > 1e-10) then
>              rTildeTmp2 = rTildeCell(k,cell2)
>            else
>              rTildeTmp2 = 1.0_RKIND
>            end if
>            ru(k,iEdge) = 0.5 * u(k,iEdge) * rTildeEdge(k,iEdge) * (rho_zz(k,cell1) / rTildeTmp1**2 &
>                             + rho_zz(k,cell2) / rTildeTmp2**2)
6026,6027c6241,6244
<             exner(k,iCell) = (zz(k,iCell) * (rgas/p0) * (rtheta_p(k,iCell) + rtheta_base(k,iCell)))**rcv
<             exner_base(k,iCell) = (zz(k,iCell) * (rgas/p0) * (rtheta_base(k,iCell)))**rcv  ! WCS addition 20180403
---
>            ! deep Eq. (23)
>            exner(k,iCell) = (zz(k,iCell) / rTildeCell(k,iCell)**2 * (rgas/p0) * (rtheta_p(k,iCell) + rtheta_base(k,iCell)))**rcv
>            ! deep Eq. (23)
>            exner_base(k,iCell) = (zz(k,iCell) / rTildeCell(k,iCell)**2 * (rgas/p0) * (rtheta_base(k,iCell)))**rcv  ! WCS addition 20180403
6033,6037c6250,6256
<             pressure_p(k,iCell) = zz(k,iCell) * rgas &
<                                                * (  exner(k,iCell) * rtheta_p(k,iCell) &
<                                                   + rtheta_base(k,iCell) * (exner(k,iCell) - exner_base(k,iCell)) &
<                                                  )
<             pressure_base(k,iCell) = zz(k,iCell) * rgas * exner_base(k,iCell) * rtheta_base(k,iCell)      ! WCS addition 20180403
---
>            ! deep Eq. (23)
>            pressure_p(k,iCell) = zz(k,iCell) / rTildeCell(k,iCell)**2 * rgas &
>                         * (  exner(k,iCell) * rtheta_p(k,iCell) &
>                          + rtheta_base(k,iCell) * (exner(k,iCell) - exner_base(k,iCell)) &
>                         )
>            ! deep Eq. (23)
>            pressure_base(k,iCell) = zz(k,iCell) / rTildeCell(k,iCell)**2 * rgas * exner_base(k,iCell) * rtheta_base(k,iCell)      ! WCS addition 20180403
diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/core_atmosphere/mpas_atm_core.F CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/core_atmosphere/mpas_atm_core.F
39a40
>       integer :: i
190,193d190
< 
<       !
<       ! Prepare the dynamics for integration
<       !
195d191
< 
295a292
>       real (kind=RKIND), dimension(:), pointer :: meshScalingRegionalCell, meshScalingRegionalEdge
510a508,510
>       ! For high-frequency diagnostics output
>       character (len=StrKIND) :: tempfilename
> 
584d583
< 
731d729
< 
782a781,782
>       ! deep
>       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell
800a801,802
>       ! deep
>       call mpas_pool_get_array(mesh, 'rTildeCell', rTildeCell)
805c807,808
<             rho(k,iCell) = rho_zz(k,iCell) * zz(k,iCell)
---
>             ! deep Eq. (13)
>             rho(k,iCell) = rho_zz(k,iCell) * zz(k,iCell) / rTildeCell(k,iCell)**2
817c820,821
<    ! Input: diag_physics  - contains physics diagnostic fields
---
>    ! Input: diag          - contains dynamics diagnostic fields
>    !        daig_physics  - contains physics diagnostic fields
908d911
< 
913d915
< 
1323d1324
< 
1339d1339
< 
diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/core_atmosphere/Registry.xml CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/core_atmosphere/Registry.xml
248a249,263
>                 <nml_option name="config_deep_atmosphere" type="logical" default_value="false" in_defaults="true"
> 		     units="-"
>                      description="Deep atmosphere configuration"
> 		     possible_values=".true. or .false."/>
>                 <nml_option name="on_a_sphere" type="logical" default_value="true" in_defaults="true"
> 		     units="-"
>                      description="Sphereical geometry?"
> 		     possible_values=".true. or .false."/>
> 
> 
> 		<nml_option name="config_weak_temperature_gradient" type="logical" default_value="false" in_defaults="true"
> 		     units="-"
> 		     description="To use barotropic fluid for tropical benchmarking tests"
> 		     possible_values=".true. or .false."/>
> 											       
250a266
>  
527a544,547
> 			<var name="rTildeCell"/>
> 			<var name="rTildeLayer"/>
> 			<var name="rTildeEdge"/>
> 			<var name="rTildeVertex"/> 
857a878,882
> 			<var name="rTildeCell"/>
> 			<var name="rTildeLayer"/>
> 			<var name="rTildeEdge"/>
> 			<var name="rTildeVertex"/> 
> 	
1426a1452,1463
>          <var name="rTildeCell" type="real" dimensions="nVertLevels nCells" units="???"
> 		     description="Nondimensional radius for cells"/>
> 
> 		<var name="rTildeLayer" type="real" dimensions="nVertLevelsP1 nCells" units="???"
>                      description="Nondimensional radius for cell layer (w) points"/>
> 
> 		<var name="rTildeEdge" type="real" dimensions="nVertLevels nEdges" units="-"
> 		     description="Nondimensional radius for edges"/>
> 
>                 <var name="rTildeVertex" type="real" dimensions="nVertLevels nVertices" units="???"
>                      description="Nondimensional radius for vertices"/> 
> 
diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/operators/mpas_vector_operations.F CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/operators/mpas_vector_operations.F
883a884,886
>         ! TODO: For periodic boundaries, locate the outer cell using the mirror image of inner cell about the edge.
>         !       The current algorithm for locating the outer cell introduces large truncation error
>         !       because x_period or y_period are much larger than dcEdge.
diff -r CAM_Jan22_backup/src/dynamics/mpas/dyn_comp.F90 CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dyn_comp.F90
133c133,136
< 
---
>    real(r8), dimension(:,:),   pointer :: rTildeVertex
>    real(r8), dimension(:,:),   pointer :: rTildeCell
>    real(r8), dimension(:,:),   pointer :: rTildeLayer
>    real(r8), dimension(:,:),   pointer :: rTildeEdge
199a203,207
>    real(r8), dimension(:,:),   pointer :: rTildeVertex
>    real(r8), dimension(:,:),   pointer :: rTildeCell
>    real(r8), dimension(:,:),   pointer :: rTildeLayer
>    real(r8), dimension(:,:),   pointer :: rTildeEdge
> 
317c325
<    use cam_mpas_subdriver, only : domain_ptr, cam_mpas_init_phase4
---
>    use cam_mpas_subdriver, only : domain_ptr, cam_mpas_init_phase4, cam_mpas_update_halo
455a464
>    
456a466,469
>    call mpas_pool_get_array(mesh_pool,  'rTildeLayer',               dyn_in % rTildeLayer )
>    call mpas_pool_get_array(mesh_pool,  'rTildeCell',               dyn_in % rTildeCell )
>    call mpas_pool_get_array(mesh_pool,  'rTildeVertex',               dyn_in % rTildeVertex )
>    call mpas_pool_get_array(mesh_pool,  'rTildeEdge',               dyn_in % rTildeEdge )
484a498,501
>    dyn_out % rTildeLayer => dyn_in % rTildeLayer
>    dyn_out % rTildeCell => dyn_in % rTildeCell
>    dyn_out % rTildeVertex => dyn_in % rTildeVertex
>    dyn_out % rTildeEdge => dyn_in % rTildeEdge
514c531,534
< 
---
>    call cam_mpas_update_halo("rTildeCell", endrun)
>    call cam_mpas_update_halo("rTildeVertex", endrun)
>    call cam_mpas_update_halo("rTildeEdge", endrun)
>    call cam_mpas_update_halo("rTildeLayer", endrun)
662a683,686
>    nullify(dyn_in % rTildeCell)
>    nullify(dyn_in % rTildeEdge)
>    nullify(dyn_in % rTildeVertex)
>    nullify(dyn_in % rTildeLayer)
698a723,726
>    nullify(dyn_out % rTildeCell)
>    nullify(dyn_out % rTildeEdge)
>    nullify(dyn_out % rTildeVertex)
>    nullify(dyn_out % rTildeLayer)
791a820
>    real(r8), pointer :: rTildeCell(:,:)
821a851
>    rTildeCell => dyn_in % rTildeCell
987c1017
<       rho_zz(:,1:nCellsSolve) = rho(:,1:nCellsSolve) / zz(:,1:nCellsSolve)
---
>       rho_zz(:,1:nCellsSolve) = rho(:,1:nCellsSolve) * rTildeCell(:,1:nCellsSolve)**2 / zz(:,1:nCellsSolve)
1063c1093
<       rho_zz(:,1:nCellsSolve) = rho(:,1:nCellsSolve) / zz(:,1:nCellsSolve)
---
>       rho_zz(:,1:nCellsSolve) = rho(:,1:nCellsSolve) * rTildeCell(:, 1:nCellsSolve)**2/ zz(:,1:nCellsSolve)
1403a1434,1435
>    logical                :: config_deep_atmosphere = .true.
>    logical                :: config_weak_temperature_gradient=.false.
1495a1528,1529
>    call mpas_pool_add_config(configPool, 'config_deep_atmosphere', config_deep_atmosphere)
>    call mpas_pool_add_config(configPool, 'config_weak_temperature_gradient', config_weak_temperature_gradient)


```