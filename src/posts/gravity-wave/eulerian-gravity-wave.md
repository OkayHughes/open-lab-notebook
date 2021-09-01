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
</details>


Then used the following setup script:


<details>
<summary>View setup.sh </summary>
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
</details>

The `user_nl_cam` used was:
<details>
<summary>View user_nl_cam </summary>
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
</details>


which should create a T341 case with two-mountain topography.

I ran `./case.build`

Resultant case is named `cesm_2.1.3.T341_f02_t12.FADIAB.gravity_wave.two_mountain_eulerian_base`


### Creating a dry SE case in NE60 resolution.


I created a new case in NE60 resolution using 


<details>
<summary>View setup.sh</summary>
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
</details>

and ran it using 

<details>
<summary>View user_nl_cam</summary>
<pre>
<code>
empty_htapes     = .TRUE.
avgflag_pertape  = 'I'
fincl1      = 'PS','T','U','V','OMEGA','T850','U850','V850','OMEGA850','PHIS','PSL','Z3'
MFILT            = 180
NHTFRQ           = -6
NDENS            = 2
analytic_ic_type = 'dry_baroclinic_wave_dcmip2016'
</code>
</pre>
</details>


Resultant case is named `cesm_2.1.3.ne60_ne60_mg16.FADIAB.gravity_wave.two_mountain_ne60_dry`


## Analyzing the results:
