---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: BW Topo figures document
  parent: Baroclinic Wave Test Case with Topography
layout: layouts/post.njk
---





### Atmospheric river similarity plot
What does this figure need to do?
* Motivate latitudinal extent and aspect ratio of wave
* Showcase moisture transport properties of wave for use in dynamical core intercomparisons
* Precipitation patterns


## Evolution:



### 5 days of MSLP in NE60
What does this figure need to do? 
* Establishes that until day 5 it is nonlinear but well behaved (lead in to convergence)
* Showcases evolving wave in relation to location of topography




Fields: 
* MSLP
* PRECL
* Precipitable water

Times: 
(day 2?) day 3, day 4, day 5, (day 6)


<details>
<summary>View SE_NE60L30_evolution.ncl </summary>
  
```
;*************************************
; SE_NE50L30_evolution.ncl
; Example usage: 
; ncl level=850 'pfmt="eps"'
;***********************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

;************************************************
begin

;=====
; declare the CAM directory and file
;=====
  fdir = "/nfs/turbo/cjablono2/owhughes/mountain_test_case_netcdf/"
  f1 = addfile(fdir+"ne60.nc","r")


;=====
 dycore   = "SEne60L30"             ; label in plot, name your dycore

;=====
; complete the plotname
;=====
    plotname = dycore+"_moist_evolution"


; ========
; define the times at which to plot
; ========

  times = (/ 12, 16, 20, 24 /)

 
;=====
; input parameter, may be specified in the command line
;=====
  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "x11"                ; default X11 window
      type = "eps"                ; default X11 window
  end if

;************************************************
; read grid variables
;************************************************
  lev  = f1->lev
  lon  = f1->lon
  lat  = f1->lat
  klev   = getfilevardimsizes(f1, "lev" ) ; read number of vertical levels (hybrid coordinates)
  
  P0   = 100000.      ; Pa
  P0mb = P0*0.01      ; hPa

;************************************************
;plot resources [options]
;************************************************
  plot = new(4 * 4,graphic)
  plot_over = new(4* 4,graphic)
  wks = gsn_open_wks(type,plotname)
  
; ********************
; FOR LOOP STARTS HERE
; ********************
do i=0,3
  pday = times(i)  ; day 5
;*************   
; read surface geopotential (first time index)
;*************   
  phis    = f1->PHIS(pday,:,:)
  
  gravity = 9.80616         ; gravitational acceleration in m/s^2
  zs      = phis/gravity    ; surface elevation
  copy_VarCoords (phis,zs)
  zs@units = "m"
  zs@long_name = "Surface height"

;************************************************
; read psl moist run 
;************************************************
  ps1      = f1->PSL(pday,:,:)                       ; (lat,lon)
  ps1_mb   = ps1*0.01
  copy_VarMeta (ps1,ps1_mb)
  ps1_mb@units = "hPa"
  printMinMax(ps1_mb,True)
  PRECL = f1->PRECL(pday,:,:)
  PRECL   = PRECL*8.64e7
  PRECL@units = "mm/day"
  PRECL@long_name = "Precipitation rate"
  
  TMQ = f1->TMQ(pday,:,:)  
  
;************************************************
  ; interpolate to constant pressure levels.
;************************************************
  p    := pres_hybrid_ccm(ps1,P0,f1->hyam,f1->hybm)          ; pressure thickness 
  copy_VarCoords(f1->Z3(pday, :, :, :), p)
  printVarSummary(p)
  temp := f1->T(pday, :, {45:45}, {30:255})
  theta := pot_temp(p(:, {45:45}, {30:255}), temp, 0, False)
  Z3 := f1->Z3(pday, :, {45:45}, {30:255})
  levels = fspan(500, 15000, 60)
  levels@units = "m"
  theta := wrf_user_interp_level(theta, Z3, levels, 0)
  printVarSummary(theta)
  theta&lon = lon({30:255})
  theta&level = levels
  printVarSummary(theta&lon)  
;=======
; open plot and define color table
;=======
;  gsn_define_colormap(wks,"WhBlGrYeRe")       ; select color table
  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
;  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")
;  gsn_define_colormap(wks,"gui_default")
;  gsn_define_colormap(wks,"precip3_16lev")
;  gsn_define_colormap(wks,"cosam12")
;  gsn_define_colormap(wks,"gui_default")

  res_overlay := True
  res_overlay@gsnDraw           = False              ; panel ... set to False
  res_overlay@gsnFrame          = False
  res_overlay@cnFillOn          = False
  res_overlay@lbLabelAutoStride = True
  res_overlay@tiMainString      = ""
  res_overlay@gsnLeftString     = ""
  res_overlay@gsnRightString    = ""
  res_overlay@vpWidthF          = 0.475
  res_overlay@vpHeightF         = 0.19
  res_overlay@cnLinesOn         = True
  res_overlay@cnLevelSelectionMode = "ManualLevels"
  res_overlay@cnMinLevelValF    = 0.                  ; set min contour level
  res_overlay@cnMaxLevelValF    = 2000.               ; set max contour level
  res_overlay@cnLevelSpacingF   = 400.                ; set contour spacing
;  res_overlay@cnLineColor        = "gray"
  res_overlay@cnLineLabelsOn    = False
  res_overlay@cnInfoLabelOn     = False

  res := True  
  res@gsnDraw           = False              ; panel ... set to False
  res@gsnFrame          = False
  res@cnFillOn          = True
  res@gsnSpreadColors   = True
;  res@gsnSpreadColorEnd = 100          ; 
  res@gsnSpreadColorStart = 7

  res@lbLabelAutoStride = True
  res@tiMainString      = ""
  res@vpKeepAspect      = True
  res@vpWidthF          = 0.475
  res@vpHeightF         = 0.19
  res@cnLinesOn         = False
  res@cnLinesOn         = True
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn     = False
  res@lbLabelBarOn      = False
;  res@pmLabelBarOrthogonalPosF  = 0.03                  ; moves label bar (up[-], down[+]) default 0.02
  res@gsnCenterString      = "Day "+pday/4.

  res@tmXBLabelFontHeightF = 0.015                 ; resize tick labels
  res@tmYLLabelFontHeightF = 0.015
  res@gsnStringFontHeightF = 0.015
  res@lbLabelFontHeightF = 0.015


  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF    = 950.                  ; set min contour level
  res@cnMaxLevelValF    = 1010.               ; set max contour level
  res@cnLevelSpacingF   = 10.                ; set contour spacing

;  res@gsnCenterString   = "Day "+pday
  
  plot(i) = gsn_csm_contour(wks,ps1_mb({0:90},{30:255}),res)
  plot_over(i) = gsn_csm_contour(wks,zs({0:90},{30:255}),res_overlay)
  overlay (plot(i),plot_over(i))

  res@cnLevelSelectionMode = "ExplicitLevels" 
  res@cnLevels             = (/ 0.10, 0.50, 1.00, 3, 5, 7.5, 10, 15, 20, 30, 40, 50, 75, 100 /)
  plot(4 + i) = gsn_csm_contour(wks,PRECL({0:90},{30:255}),res)
  plot_over(4 + i) = gsn_csm_contour(wks,zs({0:90},{30:255}),res_overlay)
  overlay (plot(4 + i),plot_over(4 + i))
  
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF    = 260.                  ; set min contour level
  res@cnMaxLevelValF    = 400.               ; set max contour level
  res@cnLevelSpacingF   = 20.                ; set contour spacing 
  res1 = True
  res1@gsnFrame = False
  res1@gsnDraw  = False
  plot(8 + i) = gsn_csm_contour(wks,theta(:,{30:255}),res) 
  plot_over(8+i) = gsn_csm_xy (wks,lon({30:255}),zs({45}, {30:255}),res1)
  overlay (plot(8+i),plot_over(8+i))
 

end do
   pres := True               ; panel
;  pres@gsnMaximize = True   ; [e]ps, pdf  make  large 
  pres@gsnMaximize = False   ; [e]ps, pdf  make  large 
;  pres@txString    = dycore+", "+diff+", "+plev+" hPa level"
;  pres@txString    = dycore+", "+plev+" hPa level"
  pres@gsnPanelYWhiteSpacePercent = 0
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnPanelLabelBar           = True
  pres@lbLabelFontHeightF       = 0.014
  pres@pmLabelBarOrthogonalPosF = -0.005           ; negative moves down like -0.03
  pres@gsnPanelFigureStringsFontHeightF = 0.011
  pres@amJust           = "TopLeft"
  pres@gsnFrame         = False   

 gsn_panel(wks,plot,(/3,4/),pres)
  frame(wks)    ; now frame the plot and we're done


end
  
```

</details>

<span class="todo">Possible evolution plot centered on the mountain at e.g. 850hPa,
this might be valuable to contrast dry with moist! </span> 


### Evolution of precipitation over mountain
Difference between PRECL in nominal 30km grid with second and without. 
* Potential lead-in to close-up comparison of structure over the mountain. 
* Hypothesis: structural characteristics of precipitation at hitting time on hill 

Fields:
* Omega
Time: day 5.


### Moist/dry comparison
* Showcases difference between dry and moist cases (e.g. why does the addition of moisture add something to this case)
* Closeup on `$$\omega $$` over mountain? Think more about this


### minimum PSL showing convergence and clustering in moist/dry case.
* shows that there is clustered agreement at high resolution in moist case, and standard
presumed "convergence" in dry case.

<span class="todo">Check whether these plots look as compelling when you just look at the 
region over the mountain</span>



### Quantitative comparison of over-mountain evolution at 850hPa (downsampled from highest resolution)
What does this show?



### Possible precipitation histogram
* Focus on time of hitting mountain, area directly over mountain.



### eddy kinetic energy plot: convergence






## Dynamical core comparison:

Closeup on evolution of precipitation in nominal 30km case over the mountain

Vertically averaged omega for showcasing physics-dynamics coupling strategy

Still unsure of gravity wave propagation. 

FV3 outlier.





