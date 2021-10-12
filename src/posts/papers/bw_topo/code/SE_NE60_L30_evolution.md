---
date: 2021-09-01
tags:
  - posts
eleventyNavigation:
  key: SE_NE60L30_evolution.ncl
  parent: Baroclinic Wave Test Case with Topography
layout: layouts/post.njk
---




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
  plot = new(2 * 4,graphic)
  plot_over = new(2 * 4,graphic)
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

  subplot_1 = gsn_panel(wks,plot(0:3),(/1,4/),pres)
  subplot_2 = gsn_panel(wks,plot(4:7),(/1,4/),pres)
  
  gsn_panel(wks,(/subplot_1, subplot_2 /),(/2,1/),pres)
  frame(wks)    ; now frame the plot and we're done


end

```