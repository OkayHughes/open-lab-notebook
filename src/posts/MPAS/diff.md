---
date: 2021-08-16
tags:
  - posts
eleventyNavigation:
  key: Porting the deep atmosphere version of MPAS to CAM-MPAS
  parent: MPAS tutorials
layout: layouts/post.njk
---


<!-- HTML generated using hilite.me --><div style="background: #ffffff; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><pre style="margin: 0; line-height: 125%"><span style="color: #000080; font-weight: bold">diff -r CAM_Jan22_backup/src/dynamics/mpas/driver/cam_mpas_subdriver.F90 CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/driver/cam_mpas_subdriver.F90</span>
330a331
&gt;        type (field2DReal), pointer :: rTildeCell
387a389
&gt;        call mpas_pool_get_subpool(domain_ptr % blocklist % structs, &#39;mesh&#39;, mesh)
391,392c393,396
&lt; 
&lt;        call mpas_pool_get_subpool(domain_ptr % blocklist % structs, &#39;mesh&#39;, mesh)
<span style="color: #aa0000">---</span>
&gt;     
&gt;        !call mpas_pool_get_field(mesh, &#39;rTildeCell&#39;, rTildeCell)
&gt;        !call mpas_dmpar_exch_halo_field(rTildeCell,(/1/))
&gt;        !call mpas_pool_get_subpool(domain_ptr % blocklist % structs, &#39;mesh&#39;, mesh)
962a967,968
&gt;        
&gt;        type (field2DReal), pointer :: rTildeVertex, rTildeCell, rTildeEdge, rTildeLayer
964d969
&lt; 
1034a1040,1043
&gt;        call mpas_pool_get_field(meshPool, &#39;rTildeVertex&#39;, rTildeVertex)
&gt;        call mpas_pool_get_field(meshPool, &#39;rTildeCell&#39;, rTildeCell)
&gt;        call mpas_pool_get_field(meshPool, &#39;rTildeLayer&#39;, rTildeLayer)
&gt;        call mpas_pool_get_field(meshPool, &#39;rTildeEdge&#39;, rTildeEdge)
1154a1164,1176
&gt;        call MPAS_streamAddField(mesh_stream, rTildeCell, ierr=ierr)
&gt;        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
&gt;        call MPAS_streamAddField(mesh_stream, rTildeVertex, ierr=ierr)
&gt;        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
&gt;        call MPAS_streamAddField(mesh_stream, rTildeEdge, ierr=ierr)
&gt;        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
&gt;        call MPAS_streamAddField(mesh_stream, rTildeLayer, ierr=ierr)
&gt;        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
&gt; 
&gt; 
&gt; 
&gt; 
&gt; 
1232a1255,1260
&gt;        
&gt; 
&gt;        call MPAS_dmpar_exch_halo_field(rTildeVertex)
&gt;        call MPAS_dmpar_exch_halo_field(rTildeEdge)
&gt;        call MPAS_dmpar_exch_halo_field(rTildeCell)
&gt;        call MPAS_dmpar_exch_halo_field(rTildeLayer)
1341a1370
&gt;        type (field2DReal), pointer :: rTildeVertex, rTildeCell, rTildeLayer, rTildeEdge
1449a1479,1484
&gt;        call mpas_pool_get_field(allFields, &#39;rTildeVertex&#39;, rTildeVertex)
&gt;        call mpas_pool_get_field(allFields, &#39;rTildeCell&#39;, rTildeCell)
&gt;        call mpas_pool_get_field(allFields, &#39;rTildeLayer&#39;, rTildeLayer)
&gt;        call mpas_pool_get_field(allFields, &#39;rTildeEdge&#39;, rTildeEdge)
&gt;  
&gt; 
1607a1643,1654
&gt; 
&gt;        call MPAS_streamAddField(restart_stream, rTildeCell, ierr=ierr)
&gt;        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
&gt;        call MPAS_streamAddField(restart_stream, rTildeVertex, ierr=ierr)
&gt;        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
&gt;        call MPAS_streamAddField(restart_stream, rTildeEdge, ierr=ierr)
&gt;        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
&gt;        call MPAS_streamAddField(restart_stream, rTildeLayer, ierr=ierr)
&gt;        if (ierr /= MPAS_STREAM_NOERR) ierr_total = ierr_total + 1
&gt; 
&gt; 
&gt; 
1834a1882,1886
&gt; 
&gt;        call cam_mpas_update_halo(&#39;rTildeCell&#39;, endrun)
&gt;        call cam_mpas_update_halo(&#39;rTildeVertex&#39;, endrun)
&gt;        call cam_mpas_update_halo(&#39;rTildeLayer&#39;, endrun)
&gt;        call cam_mpas_update_halo(&#39;rTildeEdge&#39;, endrun)
<span style="color: #000080; font-weight: bold">diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/core_atmosphere/diagnostics/pv_diagnostics.F CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/core_atmosphere/diagnostics/pv_diagnostics.F</span>
20d19
&lt; 
66d64
&lt; 
142d139
&lt; 
1244a1242,1243
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell
1259a1259,1260
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
1264c1265,1266
&lt;             rho(k,iCell) = rho_zz(k,iCell) * zz(k,iCell)
<span style="color: #aa0000">---</span>
&gt;             ! deep Eq. (13)
&gt;             rho(k,iCell) = rho_zz(k,iCell) * zz(k,iCell) / rTildeCell(k,iCell)**2
<span style="color: #000080; font-weight: bold">diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/core_atmosphere/dynamics/mpas_atm_time_integration.F CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/core_atmosphere/dynamics/mpas_atm_time_integration.F</span>
2020a2021,2022
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeLayer
2027a2030,2031
&gt;       logical, pointer :: config_weak_temperature_gradient
&gt; 
2029a2034
&gt;       call mpas_pool_get_config(configs, &#39;config_weak_temperature_gradient&#39;, config_weak_temperature_gradient)
2036a2042,2045
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeLayer&#39;, rTildeLayer)
&gt; 
2062a2072
&gt;                                    rTildeCell, rTildeLayer, &amp; ! deep
2065c2075
&lt;                                    cellSolveStart, cellSolveEnd, edgeSolveStart, edgeSolveEnd)
<span style="color: #aa0000">---</span>
&gt;                                    cellSolveStart, cellSolveEnd, edgeSolveStart, edgeSolveEnd, config_weak_temperature_gradient)
2072a2083
&gt;                                    rTildeCell, rTildeLayer, &amp; ! deep
2075c2086
&lt;                                    cellSolveStart, cellSolveEnd, edgeSolveStart, edgeSolveEnd)
<span style="color: #aa0000">---</span>
&gt;                                    cellSolveStart, cellSolveEnd, edgeSolveStart, edgeSolveEnd, config_weak_temperature_gradient)
2103a2115,2117
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
&gt;       real (kind=RKIND), dimension(nVertLevels+1,nCells+1) :: rTildeLayer
2114c2128
&lt; 
<span style="color: #aa0000">---</span>
&gt;       logical :: config_weak_temperature_gradient 
2125,2126c2139,2145
&lt;       rcv = rgas/(cp-rgas)
&lt;       c2 = cp*rcv
<span style="color: #aa0000">---</span>
&gt;       if (config_weak_temperature_gradient) then
&gt;         rcv = 0.0_RKIND
&gt;         c2 = rgas
&gt;       else
&gt;         rcv = rgas/(cp-rgas)
&gt;         c2 = cp*rcv
&gt;       end if
2137c2156,2157
&lt;             cofwr(k,iCell) =.5*dtseps*gravity*(fzm(k)*zz(k,iCell)+fzp(k)*zz(k-1,iCell))
<span style="color: #aa0000">---</span>
&gt;            cofwr(k,iCell) =.5*dtseps*gravity*(fzm(k)*zz(k  ,iCell) &amp;
&gt;                                                  +fzp(k)*zz(k-1,iCell))
2142,2144c2162,2165
&lt;             cofwz(k,iCell) = dtseps*c2*(fzm(k)*zz(k,iCell)+fzp(k)*zz(k-1,iCell))  &amp;
&lt;                  *rdzu(k)*cqw(k,iCell)*(fzm(k)*p (k,iCell)+fzp(k)*p (k-1,iCell))
&lt;             coftz(k,iCell) = dtseps*   (fzm(k)*t (k,iCell)+fzp(k)*t (k-1,iCell))
<span style="color: #aa0000">---</span>
&gt;            cofwz(k,iCell) = dtseps*c2*(fzm(k)*zz(k,iCell)+fzp(k)*zz(k-1,iCell))  &amp;
&gt;                *rdzu(k)*cqw(k,iCell)*(fzm(k)*p (k,iCell)+fzp(k)*p (k-1,iCell))  &amp;
&gt;                *(rTildeLayer(k,iCell)**2)
&gt;            coftz(k,iCell) = dtseps*   (fzm(k)*t (k,iCell)+fzp(k)*t (k-1,iCell))
2155,2157c2176,2178
&lt; 
&lt;             cofwt(k,iCell) = .5*dtseps*rcv*zz(k,iCell)*gravity*rb(k,iCell)/(1.+qtotal)  &amp;
&lt;                                 *p(k,iCell)/((rtb(k,iCell)+rt(k,iCell))*pb(k,iCell))
<span style="color: #aa0000">---</span>
&gt;             ! deep Eq. (31)
&gt;             cofwt(k,iCell) = .5*dtseps*rcv*zz(k,iCell)*gravity/rTildeCell(k,iCell)**2*rb(k,iCell)/(1.+qtotal)  &amp;
&gt;                                         *p(k,iCell)/((rtb(k,iCell)+rt(k,iCell))*pb(k,iCell))
2412a2434,2436
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeEdge
&gt; 
2425a2450,2451
&gt;       logical, pointer :: config_weak_temperature_gradient
&gt; 
2482a2509,2512
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeEdge&#39;, rTildeEdge)
&gt; 
2491a2522
&gt;       call mpas_pool_get_config(configs, &#39;config_weak_temperature_gradient&#39;, config_weak_temperature_gradient)
2500,2501c2531,2533
&lt;                                    specZoneMaskEdge, specZoneMaskCell &amp;
&lt;                                    )
<span style="color: #aa0000">---</span>
&gt;                                    rTildeCell, rTildeEdge, &amp; ! deep
&gt;                                    specZoneMaskEdge, specZoneMaskCell, &amp;
&gt;                                    config_weak_temperature_gradient)
2513,2514c2545,2547
&lt;                                    specZoneMaskEdge, specZoneMaskCell &amp;
&lt;                                    )
<span style="color: #aa0000">---</span>
&gt;                                    rTildeCell, rTildeEdge, &amp; ! deep
&gt;                                    specZoneMaskEdge, specZoneMaskCell, &amp;
&gt;                                    config_weak_temperature_gradient)
2562a2596,2599
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
&gt;       real (kind=RKIND), dimension(nVertLevels,nEdges+1) :: rTildeEdge
&gt; 
2584a2622,2624
&gt; 
&gt;       logical :: config_weak_temperature_gradient
&gt; 
2591a2632
&gt;       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
2593,2595c2634,2640
&lt; 
&lt;       rcv = rgas / (cp - rgas)
&lt;       c2 = cp * rcv
<span style="color: #aa0000">---</span>
&gt;       if (config_weak_temperature_gradient) then
&gt;         rcv = 0.0_RKIND
&gt;         c2 = rgas
&gt;       else
&gt;         rcv = rgas / (cp - rgas)
&gt;         c2 = cp * rcv
&gt;       end if
2621,2624c2666,2683
&lt;                  pgrad = ((rtheta_pp(k,cell2)-rtheta_pp(k,cell1))*invDcEdge(iEdge) )/(.5*(zz(k,cell2)+zz(k,cell1)))
&lt;                  pgrad = cqu(k,iEdge)*0.5*c2*(exner(k,cell1)+exner(k,cell2))*pgrad
&lt;                  pgrad = pgrad + 0.5*zxu(k,iEdge)*gravity*(rho_pp(k,cell1)+rho_pp(k,cell2))
&lt;                  ru_p(k,iEdge) = ru_p(k,iEdge) + dts*(tend_ru(k,iEdge) - (1.0_RKIND - specZoneMaskEdge(iEdge))*pgrad)
<span style="color: #aa0000">---</span>
&gt;                 if (rTildeCell(k,cell1) &gt; 1e-10) then
&gt;                   rTildeTmp1 = rTildeCell(k,cell1)
&gt;                 else
&gt;                   rTildeTmp1 = 1.0
&gt;                 end if
&gt;                 if (rTildeCell(k,cell1) &gt; 1e-10) then
&gt;                   rTildeTmp2 = rTildeCell(k,cell2)
&gt;                 else
&gt;                   rTildeTmp2 = 1.0
&gt;                 end if
&gt;                 ! deep Eq. (19)
&gt;                 pgrad = ((rtheta_pp(k,cell2)/rTildeTmp2**2-rtheta_pp(k,cell1)/rTildeTmp2**2)*invDcEdge(iEdge))&amp;
&gt;                         /(.5*(zz(k,cell2)+zz(k,cell1)))
&gt;                 pgrad = cqu(k,iEdge)*0.5*c2*(exner(k,cell1)+exner(k,cell2))*pgrad
&gt;                 ! deep Eq. (19) and (31)
&gt;                 pgrad = pgrad + 0.5*zxu(k,iEdge)*gravity/rTildeEdge(k,iEdge)**2 &amp; ! deep Eq. (31)
&gt;                         *(rho_pp(k,cell1)/rTildeTmp1**2+rho_pp(k,cell2)/rTildeTmp2**2) ! deep Eq. (19)
&gt;                 ru_p(k,iEdge) = ru_p(k,iEdge) + dts*(tend_ru(k,iEdge) - (1.0_RKIND - specZoneMaskEdge(iEdge))*pgrad)
2720,2728c2779,2787
&lt;             rw_p(k,iCell) = rw_p(k,iCell) +  dts*tend_rw(k,iCell)                       &amp;
&lt;                        - cofwz(k,iCell)*((zz(k  ,iCell)*ts(k)                           &amp;
&lt;                                      -zz(k-1,iCell)*ts(k-1))                            &amp;
&lt;                                +resm*(zz(k  ,iCell)*rtheta_pp(k  ,iCell)                &amp;
&lt;                                      -zz(k-1,iCell)*rtheta_pp(k-1,iCell)))              &amp;
&lt;                        - cofwr(k,iCell)*((rs(k)+rs(k-1))                                &amp;
&lt;                                +resm*(rho_pp(k,iCell)+rho_pp(k-1,iCell)))               &amp;
&lt;                        + cofwt(k  ,iCell)*(ts(k  )+resm*rtheta_pp(k  ,iCell))           &amp;
&lt;                        + cofwt(k-1,iCell)*(ts(k-1)+resm*rtheta_pp(k-1,iCell))
<span style="color: #aa0000">---</span>
&gt;            ! deep Eq. (21).
&gt;            rw_p(k,iCell) = rw_p(k,iCell) +  dts*tend_rw(k,iCell)                       &amp;
&gt;              - cofwz(k,iCell)*( zz(k  ,iCell)*(ts(k  )+resm*rtheta_pp(k,  iCell))/rTildeCell(k  ,iCell)**2   &amp;
&gt;              -zz(k-1,iCell)*(ts(k-1)+resm*rtheta_pp(k-1,iCell))/rTildeCell(k-1,iCell)**2 ) &amp;
&gt;               - cofwr(k,iCell)*((rs(k)/rTildeCell(k  ,iCell)**2+rs(k-1)/rTildeCell(k-1,iCell)**2)                                 &amp;
&gt;               +resm*(rho_pp(k,iCell)/rTildeCell(k  ,iCell)**2+rho_pp(k-1,iCell)/rTildeCell(k-1,iCell)**2))               &amp;
&gt;              + cofwt(k  ,iCell)*(ts(k  )+resm*rtheta_pp(k  ,iCell))           &amp;
&gt;               + cofwt(k-1,iCell)*(ts(k-1)+resm*rtheta_pp(k-1,iCell))
&gt; 
2798a2858,2859
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeEdge
2807a2869
&gt;       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
2811a2874,2877
&gt; 
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeEdge&#39;, rTildeEdge)
2837c2903,2912
&lt; 
<span style="color: #aa0000">---</span>
&gt;               if (rTildeCell(k,cell1) &gt; 1e-10) then
&gt;                  rTildeTmp1 = rTildeCell(k,cell1)
&gt;               else
&gt;                  rTildeTmp1 = 1.0
&gt;               end if
&gt;               if (rTildeCell(k,cell2) &gt; 1e-10) then
&gt;                  rTildeTmp2 = rTildeCell(k,cell2)
&gt;               else
&gt;                 rTildeTmp2 = 1.0
&gt;               end if
2845,2849c2920,2926
&lt;                divCell1 = -(rtheta_pp(k,cell1)-rtheta_pp_old(k,cell1))
&lt;                divCell2 = -(rtheta_pp(k,cell2)-rtheta_pp_old(k,cell2))
&lt;                ru_p(k,iEdge) = ru_p(k,iEdge) + coef_divdamp*(divCell2-divCell1)*(1.0_RKIND - specZoneMaskEdge(iEdge)) &amp;
&lt;                                                       /(theta_m(k,cell1)+theta_m(k,cell2))
&lt; 
<span style="color: #aa0000">---</span>
&gt;               ! deep Eq. (30)
&gt;               divCell1 = -(rtheta_pp(k,cell1)-rtheta_pp_old(k,cell1))/rTildeTmp1**2
&gt;               ! deep Eq. (30)
&gt;               divCell2 = -(rtheta_pp(k,cell2)-rtheta_pp_old(k,cell2))/rTildeTmp2**2
&gt;               ! deep Eq. (30)
&gt;               ru_p(k,iEdge) = ru_p(k,iEdge) + coef_divdamp*(divCell2-divCell1)*(1.0_RKIND - specZoneMaskEdge(iEdge)) &amp;
&gt;                                 /(theta_m(k,cell1)+theta_m(k,cell2)) * rTildeEdge(k,iEdge)
2883a2961,2962
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeEdge
2897a2977,2978
&gt;       logical, pointer :: config_weak_temperature_gradient
&gt; 
2953a3035,3037
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeEdge&#39;, rTildeEdge)
2954a3039
&gt;       call mpas_pool_get_config(configs, &#39;config_weak_temperature_gradient&#39;, config_weak_temperature_gradient)
2960a3046
&gt;                              rTildeCell, rTildeEdge, &amp; ! deep
2963c3049
&lt;                              cellSolveStart, cellSolveEnd, vertexSolveStart, vertexSolveEnd, edgeSolveStart, edgeSolveEnd)
<span style="color: #aa0000">---</span>
&gt;                              cellSolveStart, cellSolveEnd, vertexSolveStart, vertexSolveEnd, edgeSolveStart, edgeSolveEnd, config_weak_temperature_gradient)
2973a3060
&gt;                              rTildeCell, rTildeEdge, &amp; ! deep
2976c3063
&lt;                              cellSolveStart, cellSolveEnd, vertexSolveStart, vertexSolveEnd, edgeSolveStart, edgeSolveEnd)
<span style="color: #aa0000">---</span>
&gt;                              cellSolveStart, cellSolveEnd, vertexSolveStart, vertexSolveEnd, edgeSolveStart, edgeSolveEnd, config_weak_temperature_gradient)
3017a3105,3107
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
&gt;       real (kind=RKIND), dimension(nVertLevels,nEdges+1) :: rTildeEdge
3035c3125
&lt; 
<span style="color: #aa0000">---</span>
&gt;       logical :: config_weak_temperature_gradient
3040a3131
&gt;       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
3042,3043c3133,3137
&lt; 
&lt;       rcv = rgas/(cp-rgas)
<span style="color: #aa0000">---</span>
&gt;       if (config_weak_temperature_gradient) then
&gt;         rcv = 0.0_RKIND
&gt;       else
&gt;         rcv = rgas/(cp-rgas)
&gt;       end if
3083,3089c3177,3187
&lt;                rtheta_p(k,iCell) = rtheta_p_save(k,iCell) + rtheta_pp(k,iCell) &amp;
&lt;                                  - dt * rho_zz(k,iCell) * rt_diabatic_tend(k,iCell)
&lt;                theta_m(k,iCell) = (rtheta_p(k,iCell) + rtheta_base(k,iCell))/rho_zz(k,iCell)
&lt;                exner(k,iCell) = (zz(k,iCell)*(rgas/p0)*(rtheta_p(k,iCell)+rtheta_base(k,iCell)))**rcv
&lt;                ! pressure_p is perturbation pressure
&lt;                pressure_p(k,iCell) = zz(k,iCell) * rgas * (exner(k,iCell)*rtheta_p(k,iCell)+rtheta_base(k,iCell)  &amp;
&lt;                                                           * (exner(k,iCell)-exner_base(k,iCell)))
<span style="color: #aa0000">---</span>
&gt;               rtheta_p(k,iCell) = rtheta_p_save(k,iCell) + rtheta_pp(k,iCell) &amp;
&gt;                     - dt * rho_zz(k,iCell) * rt_diabatic_tend(k,iCell)
&gt;               theta_m(k,iCell) = (rtheta_p(k,iCell) + rtheta_base(k,iCell))/rho_zz(k,iCell)
&gt;               ! deep Eq. (23)
&gt;               exner(k,iCell) = (zz(k,iCell)/rTildeCell(k,iCell)**2*(rgas/p0)*(rtheta_p(k,iCell)+rtheta_base(k,iCell)))**rcv
&gt;               ! pressure_p is perturbation pressure
&gt;               ! deep Eq. (23)
&gt;               pressure_p(k,iCell) = zz(k,iCell) / rTildeCell(k,iCell)**2 * rgas &amp; 
&gt;                         *(exner(k,iCell)*rtheta_p(k,iCell) + rtheta_base(k,iCell)*(&amp;
&gt;                         exner(k,iCell)-exner_base(k,iCell)))
&gt;               
3113a3212,3221
&gt;             if (rTildeCell(k,cell1) &gt; 1e-10) then
&gt;                 rTildeTmp1 = rTildeCell(k,cell1)
&gt;             else
&gt;                 rTildeTmp1 = 1.0
&gt;             end if
&gt;             if (rTildeCell(k,cell2) &gt; 1e-10) then
&gt;                 rTildeTmp2 = rTildeCell(k,cell2)
&gt;             else
&gt;                 rTildeTmp2 = 1.0
&gt;             end if
3116c3224,3225
&lt;             u(k,iEdge) = 2.*ru(k,iEdge)/(rho_zz(k,cell1)+rho_zz(k,cell2))
<span style="color: #aa0000">---</span>
&gt;              u(k,iEdge) = 2.*ru(k,iEdge)/(rho_zz(k,cell1)/rTildeTmp1**2+rho_zz(k,cell2)/rTildeTmp2**2) &amp;
&gt;                          /rTildeEdge(k,iEdge)  
4346a4456,4458
&gt;       ! deep
&gt;       real(kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeLayer, rTildeEdge
&gt; 
4359a4472,4474
&gt;       logical, pointer :: config_deep_atmosphere
&gt;       logical, pointer :: on_a_sphere
&gt;       
4384a4500,4502
&gt;       call mpas_pool_get_config(configs, &#39;config_deep_atmosphere&#39;, config_deep_atmosphere)
&gt;       call mpas_pool_get_config(mesh, &#39;on_a_sphere&#39;, on_a_sphere)
&gt; 
4492a4611,4615
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeLayer&#39;, rTildeLayer)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeEdge&#39;, rTildeEdge)
&gt; 
4515a4639
&gt;          rTildeCell, rTildeLayer, rTildeEdge, &amp; ! deep
4520a4645
&gt;          config_deep_atmosphere, on_a_sphere, &amp;
4542a4668
&gt;       rTildeCell, rTildeLayer, rTildeEdge, &amp; ! deep
4547a4674
&gt;       config_deep_atmosphere, on_a_sphere, &amp;
4643a4771,4772
&gt;       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
&gt; 
4653a4783,4787
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
&gt;       real (kind=RKIND), dimension(nVertLevels+1,nCells+1) :: rTildeLayer
&gt;       real (kind=RKIND), dimension(nVertLevels,nEdges+1) :: rTildeEdge
&gt; 
4669a4804,4805
&gt;       logical, intent(in) :: config_deep_atmosphere
&gt;       logical, intent(in) :: on_a_sphere
4691c4827
&lt;       real (kind=RKIND) :: inv_r_earth
<span style="color: #aa0000">---</span>
&gt;       real (kind=RKIND) :: inv_r_earth, r_c
4716d4851
&lt;       inv_r_earth = 1.0_RKIND / r_earth
4717a4853,4857
&gt;       if (on_a_sphere) then   
&gt;          inv_r_earth = 1.0_RKIND / r_earth 
&gt;       else ! on a plane, r_earth -&gt; infinity  
&gt;          inv_r_earth = 0.0_RKIND
&gt;       endif
4814c4954
&lt;             dpdz(k,iCell) = -gravity*(rb(k,iCell)*(qtot(k,iCell)) + rr_save(k,iCell)*(1.+qtot(k,iCell)))
<span style="color: #aa0000">---</span>
&gt;             dpdz(k,iCell) = -(gravity/(rTildeCell(k,iCell)**2))*(rb(k,iCell)*(qtot(k,iCell)) + rr_save(k,iCell)*(1.+qtot(k,iCell)))
4835,4836c4975,4977
&lt;                tend_u_euler(k,iEdge) =  - cqu(k,iEdge)*( (pp(k,cell2)-pp(k,cell1))*invDcEdge(iEdge)/(.5*(zz(k,cell2)+zz(k,cell1))) &amp;
&lt;                                               -0.5*zxu(k,iEdge)*(dpdz(k,cell1)+dpdz(k,cell2)) )
<span style="color: #aa0000">---</span>
&gt;               ! deep Eq. (17)
&gt;               tend_u_euler(k,iEdge) =  - cqu(k,iEdge)*( (pp(k,cell2)-pp(k,cell1))*invDcEdge(iEdge)/(.5*(zz(k,cell2)+zz(k,cell1))) &amp;
&gt;                     -0.5*zxu(k,iEdge)*(dpdz(k,cell1)+dpdz(k,cell2))/rTildeEdge(k,iEdge)**2 )
4857c4998,4999
&lt;             tend_u(k,iEdge) = - rdzw(k)*(wduz(k+1)-wduz(k)) !  first use of tend_u
<span style="color: #aa0000">---</span>
&gt;             ! deep Eq. (17) 
&gt;             tend_u(k,iEdge) = - rdzw(k)*(wduz(k+1)-wduz(k))/rTildeEdge(k,iEdge) !  first use of tend_u
4878,4889c5020,5030
&lt;             tend_u(k,iEdge) = tend_u(k,iEdge) + rho_edge(k,iEdge)* (q(k) - (ke(k,cell2) - ke(k,cell1))       &amp;
&lt;                                                                  * invDcEdge(iEdge))                            &amp;
&lt;                                              - u(k,iEdge)*0.5*(h_divergence(k,cell1)+h_divergence(k,cell2)) 
&lt; #ifdef CURVATURE
&lt;             ! curvature terms for the sphere
&lt;             tend_u(k,iEdge) = tend_u(k,iEdge) &amp;
&lt;                              - 2.*omega*cos(angleEdge(iEdge))*cos(latEdge(iEdge))  &amp;
&lt;                                *rho_edge(k,iEdge)*.25*(w(k,cell1)+w(k+1,cell1)+w(k,cell2)+w(k+1,cell2))          &amp; 
&lt;                              - u(k,iEdge)*.25*(w(k+1,cell1)+w(k,cell1)+w(k,cell2)+w(k+1,cell2))                  &amp;
&lt;                                *rho_edge(k,iEdge) * inv_r_earth
&lt; #endif
&lt;          end do
<span style="color: #aa0000">---</span>
&gt;             ! deep Eq. (17).
&gt;             if (rTildeCell(k,cell1) &gt; 1e-10) then
&gt;                 rTildeTmp1 = rTildeCell(k,cell1)
&gt;             else
&gt;                 rTildeTmp1 = 1.0
&gt;             end if
&gt;             if (rTildeCell(k,cell2) &gt; 1e-10) then
&gt;                 rTildeTmp2 = rTildeCell(k,cell2)
&gt;             else
&gt;                 rTildeTmp2 = 1.0
&gt;             end if
4890a5032,5048
&gt;             tend_u(k,iEdge) = tend_u(k,iEdge) + 0.5 * (rho_zz(k,cell1)/rTildeTmp1**2 &amp;
&gt;                 +rho_zz(k,cell2)/rTildeTmp2**2) &amp;
&gt;                 * (q(k) - (ke(k,cell2)-ke(k,cell1))*invDcEdge(iEdge)) &amp;
&gt;                 - u(k,iEdge)*0.5*(h_divergence(k,cell1)+h_divergence(k,cell2))/rTildeEdge(k,iEdge)
&gt;          end do
&gt;          ! curvature terms for the sphere
&gt;          ! deep Eq. (17)
&gt;          if (config_deep_atmosphere) then
&gt;              do k=1,nVertLevels
&gt;                  tend_u(k,iEdge) = tend_u(k,iEdge) + (&amp;
&gt;                             - 2.*omega*cos(angleEdge(iEdge))*cos(latEdge(iEdge)) &amp;
&gt;                              *.25*(w(k,cell1)+w(k+1,cell1)+w(k,cell2)+w(k+1,cell2)) &amp;
&gt;                             - u(k,iEdge)*.25*(w(k+1,cell1)+w(k,cell1)+w(k,cell2)+w(k+1,cell2))&amp;
&gt;                             * inv_r_earth / rTildeEdge(k,iEdge) ) &amp;
&gt;                             * rho_edge(k,iEdge) / rTildeEdge(k,iEdge)
&gt;              end do
&gt;          end if
5127,5140d5284
&lt; #ifdef CURVATURE
&lt;       do iCell = cellSolveStart, cellSolveEnd
&lt; !DIR$ IVDEP
&lt;          do k=2,nVertLevels
&lt;             tend_w(k,iCell) = tend_w(k,iCell) + (rho_zz(k,iCell)*fzm(k)+rho_zz(k-1,iCell)*fzp(k))*          &amp;
&lt;                                       ( (fzm(k)*ur_cell(k,iCell)+fzp(k)*ur_cell(k-1,iCell))**2.             &amp;
&lt;                                        +(fzm(k)*vr_cell(k,iCell)+fzp(k)*vr_cell(k-1,iCell))**2. )/r_earth   &amp;
&lt;                                 + 2.*omega*cos(latCell(iCell))                                              &amp;
&lt;                                        *(fzm(k)*ur_cell(k,iCell)+fzp(k)*ur_cell(k-1,iCell))                 &amp;
&lt;                                        *(rho_zz(k,iCell)*fzm(k)+rho_zz(k-1,iCell)*fzp(k))
&lt; 
&lt;          end do
&lt;       end do
&lt; #endif
5242,5244c5386,5393
&lt;               tend_w_euler(k,iCell) = tend_w_euler(k,iCell) - cqw(k,iCell)*(   &amp;
&lt;                                            rdzu(k)*(pp(k,iCell)-pp(k-1,iCell)) &amp;
&lt;                                          - (fzm(k)*dpdz(k,iCell) + fzp(k)*dpdz(k-1,iCell)) )  ! dpdz is the buoyancy term here.
<span style="color: #aa0000">---</span>
&gt;                   ! deep Eq. (20)
&gt;                  !!  tend_w_euler(k,iCell) = tend_w_euler(k,iCell) - cqw(k,iCell)*(   &amp;
&gt;                  !!                               rdzu(k)*(pp(k,iCell)-pp(k-1,iCell)) &amp;
&gt;                  !!                             *(fzm(k)*rTildeCell(k,iCell)**2+fzp(k)*rTildeCell(k-1,iCell)**2) &amp;
&gt;                  !!                            - (fzm(k)*dpdz(k,iCell) + fzp(k)*dpdz(k-1,iCell)) )  ! dpdz is the buoyancy term here.
&gt;                  tend_w_euler(k,iCell) = tend_w_euler(k,iCell) - cqw(k,iCell)*(   &amp;
&gt;                             rdzu(k)*(pp(k,iCell)-pp(k-1,iCell))*(rTildeLayer(k,iCell)**2) &amp;
&gt;                             - (fzm(k)*dpdz(k,iCell) + fzp(k)*dpdz(k-1,iCell)) )  ! dpdz is the buoyancy term here.
5248a5398,5414
&gt;       if (config_deep_atmosphere) then
&gt;          ! call mpas_log_write(&#39;deep_atmosphere NCT terms for w&#39;)
&gt;          do iCell = cellSolveStart, cellSolveEnd
&gt;            do k=2,nVertLevels
&gt;              ! deep Eq. (20)
&gt;               !! r_c = fzm(k)*rTildeCell(k,iCell)+fzp(k)*rTildeCell(k-1,iCell)
&gt;              r_c = rTildeLayer(k,iCell)
&gt;              tend_w(k,iCell) = tend_w(k,iCell) + (r_c**2)*(&amp;
&gt;                                 fzm(k)*( (ur_cell(k  ,iCell)**2 + vr_cell(k  ,iCell)**2)*inv_r_earth/r_c  &amp;
&gt;                                  + 2.*omega*cos(latCell(iCell))*ur_cell(k  ,iCell))&amp;
&gt;                                  *rho_zz(k  ,iCell)/rTildeCell(k  ,iCell)**2&amp;
&gt;                                  +fzp(k)*( (ur_cell(k-1,iCell)**2 + vr_cell(k-1,iCell)**2)*inv_r_earth/r_c  &amp;
&gt;                                   + 2.*omega*cos(latCell(iCell))*ur_cell(k-1,iCell))&amp;
&gt;                                   *rho_zz(k-1,iCell)/rTildeCell(k-1,iCell)**2 )
&gt;            end do
&gt;          end do
&gt;       end if
5258,5259c5424,5425
&lt;                                            (w(k+1,iCell)-w(k  ,iCell))*rdzw(k)                              &amp;
&lt;                                           -(w(k  ,iCell)-w(k-1,iCell))*rdzw(k-1) )*rdzu(k)
<span style="color: #aa0000">---</span>
&gt;                   (w(k+1,iCell)-w(k  ,iCell))*rdzw(k) &amp;
&gt;                    -(w(k  ,iCell)-w(k-1,iCell))*rdzw(k-1) )*rdzu(k)
5498a5665,5666
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell, rTildeEdge, rTildeVertex
5545a5714,5718
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeEdge&#39;, rTildeEdge)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeVertex&#39;, rTildeVertex)
&gt; 
5554a5728
&gt;                rTildeCell, rTildeEdge, rTildeVertex, &amp; ! deep
5566a5741
&gt;             rTildeCell, rTildeEdge, rTildeVertex, &amp; ! deep
5603a5779,5783
&gt;     
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(nVertLevels,nCells+1) :: rTildeCell
&gt;       real (kind=RKIND), dimension(nVertLevels,nEdges+1) :: rTildeEdge
&gt;       real (kind=RKIND), dimension(nVertLevels,nVertices+1) :: rTildeVertex
5664c5844,5845
&lt;                vorticity(k,iVertex) = vorticity(k,iVertex) + s * u(k,iEdge)
<span style="color: #aa0000">---</span>
&gt;               ! deep Eq. (12)
&gt;               vorticity(k,iVertex) = vorticity(k,iVertex) + s * u(k,iEdge) * rTildeEdge(k,iEdge)
5669c5850,5851
&lt;             vorticity(k,iVertex) = vorticity(k,iVertex) * invAreaTriangle(iVertex)
<span style="color: #aa0000">---</span>
&gt;            ! deep Eq. (12)
&gt;            vorticity(k,iVertex) = vorticity(k,iVertex) * invAreaTriangle(iVertex) / rTildeVertex(k,iVertex)**2
5684c5866,5867
&lt;               divergence(k,iCell) = divergence(k,iCell) + s * u(k,iEdge)
<span style="color: #aa0000">---</span>
&gt;               ! deep Eq. (11)
&gt;               divergence(k,iCell) = divergence(k,iCell) + s * u(k,iEdge) * rTildeEdge(k,iEdge)
5689c5872,5873
&lt;             divergence(k,iCell) = divergence(k,iCell) * r
<span style="color: #aa0000">---</span>
&gt;            ! deep Eq. (11)
&gt;            divergence(k,iCell) = divergence(k,iCell) * r / rTildeCell(k,iCell)**2
5879c6063
&lt; 
<span style="color: #aa0000">---</span>
&gt;       use cam_logfile,         only: iulog
5915a6100,6105
&gt;       
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeEdge
&gt;       real (kind=RKIND) :: rTildeTmp1, rTildeTmp2
&gt; 
5918a6109
&gt;       logical, pointer :: config_weak_temperature_gradient
5955a6147,6151
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeEdge&#39;, rTildeEdge)
&gt;       call mpas_pool_get_config(configs, &#39;config_weak_temperature_gradient&#39;, config_weak_temperature_gradient)
&gt; 
5957c6153,6157
&lt;       rcv = rgas / (cp-rgas)
<span style="color: #aa0000">---</span>
&gt;       if (config_weak_temperature_gradient) then  
&gt;         rcv = 0.0_RKIND
&gt;       else 
&gt;         rcv = rgas / (cp-rgas)
&gt;       end if 
5963c6163,6165
&lt;             rho_zz(k,iCell) = rho(k,iCell) / zz(k,iCell)
<span style="color: #aa0000">---</span>
&gt;             ! deep Eq. (13)
&gt;             rho_zz(k,iCell) = rho(k,iCell) * rTildeCell(k,iCell)**2 / zz(k,iCell)
&gt;             !write(iulog,*) &quot;            k, cell1, rTildeCell&quot;,k, &#39;    &#39;, iCell, &#39;         &#39;, rTildeCell(k,iCell)**2
5973c6175,6188
&lt;             ru(k,iEdge) = 0.5 * u(k,iEdge) * (rho_zz(k,cell1) + rho_zz(k,cell2))
<span style="color: #aa0000">---</span>
&gt;            ! deep Eq. (14)
&gt;            if (rTildeCell(k,cell1) &gt; 1e-10) then
&gt;             rTildeTmp1 = rTildeCell(k,cell1)
&gt;            else
&gt;             rTildeTmp1 = 1.0_RKIND
&gt;            end if
&gt; 
&gt;            if (rTildeCell(k,cell2) &gt; 1e-10) then
&gt;              rTildeTmp2 = rTildeCell(k,cell2)
&gt;            else
&gt;              rTildeTmp2 = 1.0_RKIND
&gt;            end if
&gt;            ru(k,iEdge) = 0.5 * u(k,iEdge) * rTildeEdge(k,iEdge) * (rho_zz(k,cell1) / rTildeTmp1**2 &amp;
&gt;                             + rho_zz(k,cell2) / rTildeTmp2**2)
6026,6027c6241,6244
&lt;             exner(k,iCell) = (zz(k,iCell) * (rgas/p0) * (rtheta_p(k,iCell) + rtheta_base(k,iCell)))**rcv
&lt;             exner_base(k,iCell) = (zz(k,iCell) * (rgas/p0) * (rtheta_base(k,iCell)))**rcv  ! WCS addition 20180403
<span style="color: #aa0000">---</span>
&gt;            ! deep Eq. (23)
&gt;            exner(k,iCell) = (zz(k,iCell) / rTildeCell(k,iCell)**2 * (rgas/p0) * (rtheta_p(k,iCell) + rtheta_base(k,iCell)))**rcv
&gt;            ! deep Eq. (23)
&gt;            exner_base(k,iCell) = (zz(k,iCell) / rTildeCell(k,iCell)**2 * (rgas/p0) * (rtheta_base(k,iCell)))**rcv  ! WCS addition 20180403
6033,6037c6250,6256
&lt;             pressure_p(k,iCell) = zz(k,iCell) * rgas &amp;
&lt;                                                * (  exner(k,iCell) * rtheta_p(k,iCell) &amp;
&lt;                                                   + rtheta_base(k,iCell) * (exner(k,iCell) - exner_base(k,iCell)) &amp;
&lt;                                                  )
&lt;             pressure_base(k,iCell) = zz(k,iCell) * rgas * exner_base(k,iCell) * rtheta_base(k,iCell)      ! WCS addition 20180403
<span style="color: #aa0000">---</span>
&gt;            ! deep Eq. (23)
&gt;            pressure_p(k,iCell) = zz(k,iCell) / rTildeCell(k,iCell)**2 * rgas &amp;
&gt;                         * (  exner(k,iCell) * rtheta_p(k,iCell) &amp;
&gt;                          + rtheta_base(k,iCell) * (exner(k,iCell) - exner_base(k,iCell)) &amp;
&gt;                         )
&gt;            ! deep Eq. (23)
&gt;            pressure_base(k,iCell) = zz(k,iCell) / rTildeCell(k,iCell)**2 * rgas * exner_base(k,iCell) * rtheta_base(k,iCell)      ! WCS addition 20180403
<span style="color: #000080; font-weight: bold">diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/core_atmosphere/mpas_atm_core.F CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/core_atmosphere/mpas_atm_core.F</span>
39a40
&gt;       integer :: i
190,193d190
&lt; 
&lt;       !
&lt;       ! Prepare the dynamics for integration
&lt;       !
195d191
&lt; 
295a292
&gt;       real (kind=RKIND), dimension(:), pointer :: meshScalingRegionalCell, meshScalingRegionalEdge
510a508,510
&gt;       ! For high-frequency diagnostics output
&gt;       character (len=StrKIND) :: tempfilename
&gt; 
584d583
&lt; 
731d729
&lt; 
782a781,782
&gt;       ! deep
&gt;       real (kind=RKIND), dimension(:,:), pointer :: rTildeCell
800a801,802
&gt;       ! deep
&gt;       call mpas_pool_get_array(mesh, &#39;rTildeCell&#39;, rTildeCell)
805c807,808
&lt;             rho(k,iCell) = rho_zz(k,iCell) * zz(k,iCell)
<span style="color: #aa0000">---</span>
&gt;             ! deep Eq. (13)
&gt;             rho(k,iCell) = rho_zz(k,iCell) * zz(k,iCell) / rTildeCell(k,iCell)**2
817c820,821
&lt;    ! Input: diag_physics  - contains physics diagnostic fields
<span style="color: #aa0000">---</span>
&gt;    ! Input: diag          - contains dynamics diagnostic fields
&gt;    !        daig_physics  - contains physics diagnostic fields
908d911
&lt; 
913d915
&lt; 
1323d1324
&lt; 
1339d1339
&lt; 
<span style="color: #000080; font-weight: bold">diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/core_atmosphere/Registry.xml CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/core_atmosphere/Registry.xml</span>
248a249,263
&gt;                 &lt;nml_option name=&quot;config_deep_atmosphere&quot; type=&quot;logical&quot; default_value=&quot;false&quot; in_defaults=&quot;true&quot;
&gt; 		     units=&quot;-&quot;
&gt;                      description=&quot;Deep atmosphere configuration&quot;
&gt; 		     possible_values=&quot;.true. or .false.&quot;/&gt;
&gt;                 &lt;nml_option name=&quot;on_a_sphere&quot; type=&quot;logical&quot; default_value=&quot;true&quot; in_defaults=&quot;true&quot;
&gt; 		     units=&quot;-&quot;
&gt;                      description=&quot;Sphereical geometry?&quot;
&gt; 		     possible_values=&quot;.true. or .false.&quot;/&gt;
&gt; 
&gt; 
&gt; 		&lt;nml_option name=&quot;config_weak_temperature_gradient&quot; type=&quot;logical&quot; default_value=&quot;false&quot; in_defaults=&quot;true&quot;
&gt; 		     units=&quot;-&quot;
&gt; 		     description=&quot;To use barotropic fluid for tropical benchmarking tests&quot;
&gt; 		     possible_values=&quot;.true. or .false.&quot;/&gt;
&gt; 											       
250a266
&gt;  
527a544,547
&gt; 			&lt;var name=&quot;rTildeCell&quot;/&gt;
&gt; 			&lt;var name=&quot;rTildeLayer&quot;/&gt;
&gt; 			&lt;var name=&quot;rTildeEdge&quot;/&gt;
&gt; 			&lt;var name=&quot;rTildeVertex&quot;/&gt; 
857a878,882
&gt; 			&lt;var name=&quot;rTildeCell&quot;/&gt;
&gt; 			&lt;var name=&quot;rTildeLayer&quot;/&gt;
&gt; 			&lt;var name=&quot;rTildeEdge&quot;/&gt;
&gt; 			&lt;var name=&quot;rTildeVertex&quot;/&gt; 
&gt; 	
1426a1452,1463
&gt;          &lt;var name=&quot;rTildeCell&quot; type=&quot;real&quot; dimensions=&quot;nVertLevels nCells&quot; units=&quot;???&quot;
&gt; 		     description=&quot;Nondimensional radius for cells&quot;/&gt;
&gt; 
&gt; 		&lt;var name=&quot;rTildeLayer&quot; type=&quot;real&quot; dimensions=&quot;nVertLevelsP1 nCells&quot; units=&quot;???&quot;
&gt;                      description=&quot;Nondimensional radius for cell layer (w) points&quot;/&gt;
&gt; 
&gt; 		&lt;var name=&quot;rTildeEdge&quot; type=&quot;real&quot; dimensions=&quot;nVertLevels nEdges&quot; units=&quot;-&quot;
&gt; 		     description=&quot;Nondimensional radius for edges&quot;/&gt;
&gt; 
&gt;                 &lt;var name=&quot;rTildeVertex&quot; type=&quot;real&quot; dimensions=&quot;nVertLevels nVertices&quot; units=&quot;???&quot;
&gt;                      description=&quot;Nondimensional radius for vertices&quot;/&gt; 
&gt; 
<span style="color: #000080; font-weight: bold">diff -r CAM_Jan22_backup/src/dynamics/mpas/dycore/src/operators/mpas_vector_operations.F CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dycore/src/operators/mpas_vector_operations.F</span>
883a884,886
&gt;         ! TODO: For periodic boundaries, locate the outer cell using the mirror image of inner cell about the edge.
&gt;         !       The current algorithm for locating the outer cell introduces large truncation error
&gt;         !       because x_period or y_period are much larger than dcEdge.
<span style="color: #000080; font-weight: bold">diff -r CAM_Jan22_backup/src/dynamics/mpas/dyn_comp.F90 CAM_Jan22_deep_mpas_fix/src/dynamics/mpas/dyn_comp.F90</span>
133c133,136
&lt; 
<span style="color: #aa0000">---</span>
&gt;    real(r8), dimension(:,:),   pointer :: rTildeVertex
&gt;    real(r8), dimension(:,:),   pointer :: rTildeCell
&gt;    real(r8), dimension(:,:),   pointer :: rTildeLayer
&gt;    real(r8), dimension(:,:),   pointer :: rTildeEdge
199a203,207
&gt;    real(r8), dimension(:,:),   pointer :: rTildeVertex
&gt;    real(r8), dimension(:,:),   pointer :: rTildeCell
&gt;    real(r8), dimension(:,:),   pointer :: rTildeLayer
&gt;    real(r8), dimension(:,:),   pointer :: rTildeEdge
&gt; 
317c325
&lt;    use cam_mpas_subdriver, only : domain_ptr, cam_mpas_init_phase4
<span style="color: #aa0000">---</span>
&gt;    use cam_mpas_subdriver, only : domain_ptr, cam_mpas_init_phase4, cam_mpas_update_halo
455a464
&gt;    
456a466,469
&gt;    call mpas_pool_get_array(mesh_pool,  &#39;rTildeLayer&#39;,               dyn_in % rTildeLayer )
&gt;    call mpas_pool_get_array(mesh_pool,  &#39;rTildeCell&#39;,               dyn_in % rTildeCell )
&gt;    call mpas_pool_get_array(mesh_pool,  &#39;rTildeVertex&#39;,               dyn_in % rTildeVertex )
&gt;    call mpas_pool_get_array(mesh_pool,  &#39;rTildeEdge&#39;,               dyn_in % rTildeEdge )
484a498,501
&gt;    dyn_out % rTildeLayer =&gt; dyn_in % rTildeLayer
&gt;    dyn_out % rTildeCell =&gt; dyn_in % rTildeCell
&gt;    dyn_out % rTildeVertex =&gt; dyn_in % rTildeVertex
&gt;    dyn_out % rTildeEdge =&gt; dyn_in % rTildeEdge
514c531,534
&lt; 
<span style="color: #aa0000">---</span>
&gt;    call cam_mpas_update_halo(&quot;rTildeCell&quot;, endrun)
&gt;    call cam_mpas_update_halo(&quot;rTildeVertex&quot;, endrun)
&gt;    call cam_mpas_update_halo(&quot;rTildeEdge&quot;, endrun)
&gt;    call cam_mpas_update_halo(&quot;rTildeLayer&quot;, endrun)
662a683,686
&gt;    nullify(dyn_in % rTildeCell)
&gt;    nullify(dyn_in % rTildeEdge)
&gt;    nullify(dyn_in % rTildeVertex)
&gt;    nullify(dyn_in % rTildeLayer)
698a723,726
&gt;    nullify(dyn_out % rTildeCell)
&gt;    nullify(dyn_out % rTildeEdge)
&gt;    nullify(dyn_out % rTildeVertex)
&gt;    nullify(dyn_out % rTildeLayer)
791a820
&gt;    real(r8), pointer :: rTildeCell(:,:)
821a851
&gt;    rTildeCell =&gt; dyn_in % rTildeCell
987c1017
&lt;       rho_zz(:,1:nCellsSolve) = rho(:,1:nCellsSolve) / zz(:,1:nCellsSolve)
<span style="color: #aa0000">---</span>
&gt;       rho_zz(:,1:nCellsSolve) = rho(:,1:nCellsSolve) * rTildeCell(:,1:nCellsSolve)**2 / zz(:,1:nCellsSolve)
1063c1093
&lt;       rho_zz(:,1:nCellsSolve) = rho(:,1:nCellsSolve) / zz(:,1:nCellsSolve)
<span style="color: #aa0000">---</span>
&gt;       rho_zz(:,1:nCellsSolve) = rho(:,1:nCellsSolve) * rTildeCell(:, 1:nCellsSolve)**2/ zz(:,1:nCellsSolve)
1403a1434,1435
&gt;    logical                :: config_deep_atmosphere = .true.
&gt;    logical                :: config_weak_temperature_gradient=.false.
1495a1528,1529
&gt;    call mpas_pool_add_config(configPool, &#39;config_deep_atmosphere&#39;, config_deep_atmosphere)
&gt;    call mpas_pool_add_config(configPool, &#39;config_weak_temperature_gradient&#39;, config_weak_temperature_gradient)
</pre></div>
