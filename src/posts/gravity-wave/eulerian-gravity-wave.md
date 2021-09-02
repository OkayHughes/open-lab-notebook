---
date: 2021-08-30
tags:
  - posts
  - gravity_wave
eleventyNavigation:
  key: Using the CAM Eulerian dynamical core to explore the 2MGW
  parent: The two-mountain gravity wave
layout: layouts/post.njk
---

The Eulerian Spectral dycore in [CAM](https://www.cesm.ucar.edu/models/atm-cam/)
is one of the most computationally efficient ways of solving the primitive equations of motion
for atmospheric flows. 

However, it has several important design considerations
that make it useful for studying the gravity wave that's been giving us so much trouble.
Firstly, it is formulated using Temperature in `$$ K $$` rather than potential temperature `$$ \theta $$`. The second is that 
there is no implicit representation of diffusion and it must be added as a namelist parameter.
This allows us to test whether decreasing the strength of horizontal diffusion prevents the wave from being damped.


### Ensuring that the signature is present in the T341 resolution runs.


Created a new case in T341 resolution using 

<details>
<summary>View create.sh </summary>
<p>
<pre>
<code>
change_cesm

CASE_ID="two_mountain_eulerian_base"
COMPSET="T341_f02_t12"
SETUP_SCRIPT=basic_dry.sh
PE_COUNT=216
export CESM_GROUP="gravity_wave"
PHYSICS="FADIAB"
CASE_NAME="${CESM_VERSION}.${COMPSET}.${PHYSICS}.${CESM_GROUP}.${CASE_ID}"
CASE_DIR=${MY_CESM_CASES}/${CESM_GROUP}/${CASE_NAME}


if [ -d "${CASE_DIR}" ] 
then
	read -p "Case exists: overwrite it? [y, N]: " flag
	echo ${flag}
	if [ ${flag} != "y" ]
	then
		exit 0
	fi
	rm -rf "${CASE_DIR}"
fi


yes r | ~/cesm/cime/scripts/create_newcase --compset ${PHYSICS} --run-unsupported --res ${COMPSET} --case ${CASE_DIR} --pecount ${PE_COUNT}

ln -s ${MY_CESM_ROOT}/output/${CASE_NAME} ${CASE_DIR}


ln -s ${CASE_DIR} ${MY_CESM_ROOT}/output/${CASE_NAME}

cp ${MY_CESM_CASES}/setup_scripts/${SETUP_SCRIPT} ${CASE_DIR}/setup.sh

echo ${CASE_NAME}
</code>
</pre>
</p>
</details>


Then used the following setup script:


<details>
<summary>View setup.sh </summary>
<p>
<pre>
<code>
CAM_CONFIG_OPTS="--phys adiabatic  --analytic_ic"
STOP_OPTION=ndays
STOP_N=6
hours=0
minutes=30
seconds=00
ANALYTIC_IC="dry_baroclinic_wave_dcmip2016"
MAX_RUNTIME=${hours}:${minutes}:${seconds}
BC_COMP_MOD=ic_gravity.F90

./xmlchange STOP_OPTION=${STOP_OPTION},STOP_N=${STOP_N}
./xmlchange DOUT_S=FALSE
./xmlchange JOB_WALLCLOCK_TIME=${MAX_RUNTIME}
./xmlquery CAM_CONFIG_OPTS
./case.setup

./xmlchange --file env_build.xml --id CAM_CONFIG_OPTS --val "${CAM_CONFIG_OPTS}"

cp ${MY_CESM_CASES}/user_nl_cams/eulerian/eulerian_T341_user_nl_cam user_nl_cam
additions="analytic_ic_type = '$ANALYTIC_IC'"
echo "${additions}" >> user_nl_cam
cp ${MY_CESM_CASES}/comp_mods/${BC_COMP_MOD} SourceMods/src.cam/ic_baroclinic.F90

</code>
</pre>
</p>
</details>

The `user_nl_cam` used was:
<details>
<summary>View user_nl_cam </summary>
<p>
<pre>
<code>
empty_htapes     = .TRUE.
avgflag_pertape  = 'I'
fincl1      = 'PS','T','U','V','OMEGA','T850','U850','V850','OMEGA850','PHIS','PSL','Z3'
MFILT            = 180
NHTFRQ           = -6
NDENS            = 2
eul_nsplit       = 1
eul_hdif_coef    = 1.5D13
analytic_ic_type = 'dry_baroclinic_wave_dcmip2016'

</code>
</pre>
</p>
</details>


which should create a T341 case with two-mountain topography.

I ran `./case.build`

Resultant case is named `cesm_2.1.3.T341_f02_t12.FADIAB.gravity_wave.two_mountain_eulerian_base`


### Creating a dry SE case in NE30 resolution.


I created a new case in NE30 resolution using


<details>
<summary>View create.sh</summary>
<p>
<pre>
<code>
change_cesm

CASE_ID="two_mountain_ne30_dry"
COMPSET="ne30_ne30_mg16"
SETUP_SCRIPT=basic_dry.sh
PE_COUNT=72
export CESM_GROUP="gravity_wave"
PHYSICS="FADIAB"
CASE_NAME="${CESM_VERSION}.${COMPSET}.${PHYSICS}.${CESM_GROUP}.${CASE_ID}"
CASE_DIR=${MY_CESM_CASES}/${CESM_GROUP}/${CASE_NAME}


if [ -d "${CASE_DIR}" ] 
then
	read -p "Case exists: overwrite it? [y, N]: " flag
	echo ${flag}
	if [ ${flag} != "y" ]
	then
		exit 0
	fi
	rm -rf "${CASE_DIR}"
fi


yes r | ~/cesm/cime/scripts/create_newcase --compset ${PHYSICS} --run-unsupported --res ${COMPSET} --case ${CASE_DIR} --pecount ${PE_COUNT}

ln -s ${MY_CESM_ROOT}/output/${CESM_GROUP}/${CASE_NAME} ${CASE_DIR}/out_dir



cp ${MY_CESM_CASES}/setup_scripts/${SETUP_SCRIPT} ${CASE_DIR}/setup.sh

cd ${CASE_DIR}
source setup.sh
cd ${currentdir}

ln -sf ${CASE_DIR} ${MY_CESM_ROOT}/output/${CESM_GROUP}/${CASE_NAME}/case_dir

echo ${CASE_NAME}
</code>
</pre>
</p>
</details>


<details>
<summary>View setup.sh</summary>
<p>
<pre>
<code>
CAM_CONFIG_OPTS="--phys adiabatic  --analytic_ic"
STOP_OPTION=ndays
STOP_N=6
hours=0
minutes=15
seconds=00
ANALYTIC_IC="moist_baroclinic_wave_dcmip2016"
MAX_RUNTIME=${hours}:${minutes}:${seconds}
BC_COMP_MOD=ic_gravity.F90

./xmlchange STOP_OPTION=${STOP_OPTION},STOP_N=${STOP_N}
./xmlchange DOUT_S=FALSE
./xmlchange JOB_WALLCLOCK_TIME=${MAX_RUNTIME}
./xmlquery CAM_CONFIG_OPTS
./case.setup

./xmlchange --file env_build.xml --id CAM_CONFIG_OPTS --val "${CAM_CONFIG_OPTS}"

cp ${MY_CESM_CASES}/user_nl_cams/user_nl_cam user_nl_cam
additions="analytic_ic_type = '$ANALYTIC_IC'"
echo "${additions}" >> user_nl_cam
cp ${MY_CESM_CASES}/comp_mods/${BC_COMP_MOD} SourceMods/src.cam/ic_baroclinic.F90

</code>
</pre>
</p>
</details>

and ran it using 

<details>
<summary>View user_nl_cam</summary>
<p>
<pre>
<code>
empty_htapes     = .TRUE.
avgflag_pertape  = 'I'
fincl1      = 'PS','T','U','V','OMEGA','T850','U850','V850','OMEGA850','PHIS','PSL','Z3'
MFILT            = 180
NHTFRQ           = -6
NDENS            = 2
analytic_ic_type = 'dry_baroclinic_wave_dcmip2016'
interpolate_output = .true.
</code>
</pre>
</p>
</details>


Resultant case is named `cesm_2.1.3.ne60_ne60_mg16.FADIAB.gravity_wave.two_mountain_ne60_dry`

### Analyzing the results:


These images were created with 
<details>
<summary>this ncl script</summary>
<p>
<pre>
<code>
	dir_root = "/scratch/cjablono_root/cjablono1/owhughes/netcdf_storage/gravity_wave/"
	diris = (/ dir_root + "",\
		  dir_root + ""/)

; specify (absolute) paths to files, and the labels that should appear in the figure
	fnames = (/ "cesm_2.1.3.ne30_ne30_mg16.FADIAB.gravity_wave.two_mountain_ne30_dry.cam.h0.0001-01-01-00000.nc", \
		    "cesm_2.1.3.T341_f02_t12.FADIAB.gravity_wave.two_mountain_eulerian_base.cam.h0.0001-01-01-00000.nc"/)
	labels = (/ "NE60", "T341"/)
	time_mult = (/ 1, 1/)

	;fname = "flat.cam.h0.nc"
	dir_fig = "T341_ne30_compare"
	time_ind = 2 ; the time in days that we want to plot
	comp_identifier =  "time_" + time_ind
	;fname = "flat.cam.h0.nc"


	i = 0

; Setup workstation and figure render presets
	label = "OMEGA"
	out = systemfunc("mkdir -p " + "figures/" + dir_fig + "/" + comp_identifier)
	wks_type = "png"
	wks_type@wkWidth = 1024
	wks_type@wkHeight = 1024
	wks_frame = gsn_open_wks(wks_type, "figures/" + dir_fig + "/" +  label + time_ind )
	
	dimsz = dimsizes(fnames)
	plot_tmp = new(2 * (dimsz(0)),graphic)
	plot = new(dimsz(0),graphic)
	minval = (/ -0.1, -0.1 /)
	maxval = (/ 0.1, 0.1 /)
	t_out = 0.0
	i = 0
	lat_begin = -90
	lat_end = 90
	lon_begin = -360
	lon_end = 360
	do while(i.lt. dimsz(0))
		print(i)
		f     = addfile(diris(i) + fnames(i),"r")
		time := f->time
		lat := f->lat
		lon := f->lon
		latsize := dimsizes(lat)
		phi_dims = getfilevardimsizes(f, "PHIS")
		nlat := 0
                if (product(dimsizes(phi_dims)) .eq. 2) then 
                        phi_surf_all := f->PHIS({lat_begin:lat_end}, {lon_begin:lon_end}) 
                else
                        phi_surf_all := f->PHIS(0, {lat_begin:lat_end}, {lon_begin:lon_end}) 
                end if  
		phi_surf := phi_surf_all
		var_all := f->OMEGA850({time_ind}, :, :)
		Z3 := f->Z3({time_ind}, :, :, :)
		var := var_all({-360:360}, {-360:360}) 
		t_out := time({time_ind})
		
		
	
	
	
		res                     = True         ; plot modifications desired
		res@gsnDraw  = False
		res@gsnFrame = False
		res@vpWidthF             = 0.9
		res@vpHeightF            = 0.225
		res@gsnMaximize         = True         ; Maximize size of plot in frame
		res@cnFillOn            = True
		res@cnFillPalette       = "MPL_rainbow"
		res@cnLinesOn           = False
		res@cnLineLabelsOn      = False
		res@lbLabelAngleF       = 90
		res@tiMainString        = ""
		res@tiMainOn = False
		res@tiYAxisString = labels(i)
		res@cnLevelSelectionMode = "ManualLevels"
		res@cnMinLevelValF  = minval(i)
		res@cnMaxLevelValF  = maxval(i)
		res@cnLevelSpacingF = (maxval(i)-minval(i)) / 10
		plot_tmp(2 * i) = gsn_csm_contour(wks_frame,var(:, :),res)
		res_geo                     = True
		res_geo@gsnDraw  = False
		res_geo@gsnFrame = False
		res_geo@cnConstFLabelOn = False
		res_geo@vpWidthF             = 0.9
		res_geo@vpHeightF            = 0.225
		res_geo@gsnMaximize         = True 
		res_geo@cnFillOn = False
		res_geo@cnLinesOn = True
		res_geo@cnLineLabelsOn = False
		res_geo@tiMainString = ""
		res_geo@gsnRightString   = ""
		res_geo@gsnLeftString    = ""
		res_geo@gsnCenterString  = ""
		res_geo@cnLineColor      = "black"
		res_geo@cnInfoLabelOn = False
                res_geo@cnLevelSelectionMode = "ExplicitLevels"
                res_geo@cnLevels = (/ 0.1 * max(phi_surf(:, :)), max(phi_surf(:, :)) / 2, 0.9 * max(phi_surf(:, :)) /)
		res_geo@cnLineLabelBackgroundColor = "transparent"
		plot_tmp(2*i + 1) =  gsn_csm_contour(wks_frame,phi_surf(:, :),res_geo)


		overlay(plot_tmp(2 * i), plot_tmp(2 * i + 1))
		plot(i) = plot_tmp(2 * i)
	
		i = i + 1

	end do
	res_panel = True
	res_panel@gsnPanelMainString        = label + " "  + " day " + sprintf("%5.2f"    , t_out)
	gsn_panel(wks_frame,plot,(/2, 1/), res_panel)
</code>
</pre>
</p>
</details>

<img class="center small" alt="Omega 850 day 0.5" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/eulerian_dycore_compare/OMEGA0.5.png">
<img class="center small" alt="Omega 850 day 1" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/eulerian_dycore_compare/OMEGA1.png">
<img class="center small" alt="Omega 850 day 1.5" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/eulerian_dycore_compare/OMEGA1.5.png">
<img class="center small" alt="Omega 850 day 2" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/eulerian_dycore_compare/OMEGA2.png">

This shows propagation of the gravity wave in the Spectral Eulerian dynamical core. 


### Reducing diffusion in T341

I will now create an approximately 1 day run with halved diffusion constant in the namelist.

I created the case using 

<details>
<summary>create.sh</summary>
<p>
<pre>
<code>
change_cesm

CASE_ID="two_mountain_T341_red_diffusion"
COMPSET="T341_f02_t12"
SETUP_SCRIPT=basic_dry.sh
PE_COUNT=216
export CESM_GROUP="gravity_wave"
PHYSICS="FADIAB"
CASE_NAME="${CESM_VERSION}.${COMPSET}.${PHYSICS}.${CESM_GROUP}.${CASE_ID}"
CASE_DIR=${MY_CESM_CASES}/${CESM_GROUP}/${CASE_NAME}


if [ -d "${CASE_DIR}" ] 
then
	read -p "Case exists: overwrite it? [y, N]: " flag
	echo ${flag}
	if [ ${flag} != "y" ]
	then
		exit 0
	fi
	rm -rf "${CASE_DIR}"
fi


yes r | ~/cesm/cime/scripts/create_newcase --compset ${PHYSICS} --run-unsupported --res ${COMPSET} --case ${CASE_DIR} --pecount ${PE_COUNT}

ln -s ${MY_CESM_ROOT}/output/${CESM_GROUP}/${CASE_NAME} ${CASE_DIR}/out_dir



cp ${MY_CESM_CASES}/setup_scripts/${SETUP_SCRIPT} ${CASE_DIR}/setup.sh

cd ${CASE_DIR}
source setup.sh
cd ${currentdir}

ln -sf ${CASE_DIR} ${MY_CESM_ROOT}/output/${CESM_GROUP}/${CASE_NAME}/case_dir

echo ${CASE_NAME}
</code>
</pre>
</p>
</details>


and 

<details>
<summary>setup.sh</summary>
<p>
<pre>
<code>
CAM_CONFIG_OPTS="--phys adiabatic  --analytic_ic"
STOP_OPTION=ndays
STOP_N=6
hours=0
minutes=15
seconds=00
ANALYTIC_IC="dry_baroclinic_wave_dcmip2016"
MAX_RUNTIME=${hours}:${minutes}:${seconds}
BC_COMP_MOD=ic_gravity.F90

./xmlchange STOP_OPTION=${STOP_OPTION},STOP_N=${STOP_N}
./xmlchange DOUT_S=FALSE
./xmlchange JOB_WALLCLOCK_TIME=${MAX_RUNTIME}
./xmlquery CAM_CONFIG_OPTS
./case.setup

./xmlchange --file env_build.xml --id CAM_CONFIG_OPTS --val "${CAM_CONFIG_OPTS}"

cp ${MY_CESM_CASES}/user_nl_cams/user_nl_cam user_nl_cam
additions="analytic_ic_type = '$ANALYTIC_IC'"
echo "${additions}" >> user_nl_cam
cp ${MY_CESM_CASES}/comp_mods/${BC_COMP_MOD} SourceMods/src.cam/ic_baroclinic.F90
</code>
</pre>
</p>
</details>



With `user_nl_cam` 
<details>
<summary>setup.sh</summary>
<p>
<pre>
<code>
empty_htapes     = .TRUE.
avgflag_pertape  = 'I'
fincl1      = 'PS','T','U','V','OMEGA','T850','U850','V850','OMEGA850','PHIS','PSL','Z3'
MFILT            = 180
NHTFRQ           = -6
NDENS            = 2
eul_nsplit       = 1
eul_hdif_coef    = 0.75D13
analytic_ic_type = 'dry_baroclinic_wave_dcmip2016'
</code>
</pre>
</p>
</details>


The resulting case name is `cesm_2.1.3.T341_f02_t12.FADIAB.gravity_wave.two_mountain_T341_red_diffusion`.


### Comparing T341 cases with decreased diffusion

<img class="center medium" alt="Omega 850 day 0.5" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/diff_compare/OMEGA0.5.png">
<img class="center medium" alt="Omega 850 day 1.0" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/diff_compare/OMEGA1.png">
<img class="center medium" alt="Omega 850 day 1.5" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/diff_compare/OMEGA1.5.png">
<img class="center medium" alt="Omega 850 day 2.0" src="https://open-lab-notebook-assets.glitch.me/assets/gravity_wave/diff_compare/OMEGA2.png">

Clearly decreasing the strength of horizontal diffusion does not change the evolution of this gravity wave.
