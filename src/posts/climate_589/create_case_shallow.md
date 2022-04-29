---
date: 2021-08-30
tags:
  - posts
  - climate_589
eleventyNavigation:
  parent: Climate 589
  key: Make deep atmosphere aquaplanet
layout: layouts/post.njk
---

```


export CESMDATAROOT=$SCRATCH/CESM_INPUT
readonly CESM_PREFIX="CAM_Jan22_var_res"
readonly COMPSET="2000_CAM40_SLND_SICE_DOCN%AQP1_SROF_SGLC_SWAV"
readonly GRID_NAME="mpasa120-30_mpasa120-30"
readonly GROUP_NAME="589_final_project"
readonly CASE_ID="AQP_spinup"
readonly PROJECT="UMIC0087"
readonly NPROCS="288"

# =================
readonly CASE_DIR="${HOME}/CESM_CASE_DIRS/${CESM_PREFIX}_CASES/${CESM_PREFIX}/${GROUP_NAME}"
readonly SRC_DIR="${HOME}/CESM_SRC_DIRS/${CESM_PREFIX}"
readonly CASE_NAME="${CESM_PREFIX}.${GRID_NAME}.${COMPSET}.${GROUP_NAME}.${CASE_ID}"
readonly BUILD_ROOT="/glade/scratch/${USER}/$CASE_NAME"
# =================


change_cesm() {
    local cesm_prefix=$1
    rm "${HOME}/cesm_src"
    rm "${HOME}/cesm_cases"
    local src_dir="${HOME}/CESM_SRC_DIRS/$cesm_prefix/"
    if is_dir ${src_dir}; then
        ln -s ${src_dir} "${HOME}/cesm_src"
    else
        echo "${src_dir} does not exist!"
        exit
    fi
    local case_dir="${HOME}/CESM_CASE_DIRS/${cesm_prefix}_CASES/"
    if is_dir ${case_dir}; then
        ln -s ${case_dir} "${HOME}/cesm_cases"
    else
        echo "${case_dir} does not exist!"
        exit
    fi
    
}

handle_case_exists() {
    local abs_case_dir=$1
    cat << EOF
Case directory 
${abs_case_dir} 
already exists! 

Cowardly refusing to overwrite it :(

EOF
    exit 1

}

create_case(){
    is_dir "${CASE_DIR}/${CASE_NAME}" \
        && handle_case_exists "${CASE_DIR}/${CASE_NAME}"
    yes r | ${SRC_DIR}/cime/scripts/create_newcase --compset "${COMPSET}" --res ${GRID_NAME} --case ${CASE_DIR}/${CASE_NAME} --run-unsupported --project ${PROJECT} --pecount ${NPROCS}
}

create_xml_config_helper() {
    local config_script="$CASE_DIR/${CASE_NAME}/xml_config_helper.sh"
    cat << EOF > $config_script

# ------------------

readonly DEBUG=FALSE

# ------------------
# set this to true if you want an archive directory

readonly DOUT_S=FALSE

#-------------------
# valid options for this value are:
#  nsteps, nseconds, nminutes, nhours, ndays, nmonths, nyears

readonly STOP_OPTION=nmonths

# ------------------

readonly STOP_N=24


readonly ATM_NCPL=288

# ------------------
# Set the frequency at which files for restarting the model (e.g. in the 
# case of a blowup) are written. If TRUE, make sure to set REST_N

readonly REST_OPTION=nmonths
readonly REST_N=1

# ====================
# CAM build flag (note: this is quite finicky and causes compiler errors if done wrong)

readonly CAM_CONFIG_OPTS="--phys cam4 --aquaplanet --analytic_ic --nlev=30"

# --------------------
# Maximum runtime:

readonly HOURS=11
readonly MINUTES=50
readonly SECONDS=00

# --------------------

main() {
    ./xmlchange DEBUG=\${DEBUG},DOUT_S=\${DOUT_S},STOP_OPTION=\${STOP_OPTION},STOP_N=\${STOP_N},REST_OPTION=\${REST_OPTION},REST_N=\${REST_N},ATM_NCPL=\${ATM_NCPL} \
        && ./xmlchange --file env_build.xml --id CAM_CONFIG_OPTS --val "\${CAM_CONFIG_OPTS}" \
        && ./xmlquery CAM_CONFIG_OPTS \
        && ./xmlchange JOB_WALLCLOCK_TIME=\${HOURS}:\${MINUTES}:\${SECONDS} \
        && ./case.setup

}


main
EOF
}

create_user_nl_cam() {
    local config_script="$CASE_DIR/${CASE_NAME}/user_nl_cam"
    cat << EOF > $config_script
    ncdata  = '/glade/u/home/owhughes/grids/x4.92067/x4.92067.init.deep.nc'
    mpas_block_decomp_file_prefix = "/glade/u/home/owhughes/grids/x4.92067/x4.92067.graph.info.part."
    drydep_srf_file="/glade/u/home/owhughes/grids/stub_data/atmsrf_mpasa120-30.nc"
    mpas_dt = 100.0
    omega   = 0.00014584 
    rearth  = 3185500.0
    mpas_len_disp = 15000
    analytic_ic_type = 'moist_baroclinic_wave_dcmip2016'
    empty_htapes     = .TRUE.
    NDENS            = 2,2
    fincl1           = 'SST:A','PHIS:A','PS:A','T:A','U:A','V:A','OMEGA:A','Q:A','ATMEINT:A','CLDICE:A','CLDLIQ:A','CLOUD:A','CLDTOT:A','PRECL:A','PRECC:A','PRECT:A','TMQ:A','TMCLDICE:A','TMCLDLIQ:A','SHFLX:A','LHFLX:A','QFLX:A','RELHUM:A','FLUT:A','U200:A','V200:A'
    fincl2           = 'PS:I','SHFLX:I','LHFLX:I','FLUT:I','TMQ:I','CLDTOT:I','PRECC:I','PRECT:I','U200:I','V200:I'
    MFILT            = 280, 721
    NHTFRQ           = -720, -24
    inithist         = 'ENDOFRUN'

EOF

}

create_preview_namelists_helper() {
    local config_script="$CASE_DIR/${CASE_NAME}/preview_namelists_helper.sh"
    cat << EOF > $config_script
./preview_namelists > preview_namelists.log 2> preview_namelists.err 
EOF
}

create_case_build_helper() {
    local config_script="$CASE_DIR/${CASE_NAME}/case_build_helper.sh" 
    echo "qcmd -A ${PROJECT} -- ${CASE_DIR}/${CASE_NAME}/case.build" > $config_script
}




main() {
    change_cesm ${CESM_PREFIX}
    create_case \
        && create_xml_config_helper \
        && create_user_nl_cam \
        && create_preview_namelists_helper \
        && create_case_build_helper
    
}


# ============================================================================
# begin namelist
# ============================================================================

# ===========================================================================


# ============================================================================
# begin boilerplate 
# ============================================================================

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

is_empty() {
    local var=$1

    [[ -z $var ]]
}

is_not_empty() {
    local var=$1

    [[ -n $var ]]
}

is_file() {
    local file=$1

    [[ -f $file ]]
}

is_link() {
    local var=$1

    [[ `test -L $1` ]]
}


is_dir() {
    local dir=$1

    [[ -d $dir ]]
}


# =================================================================
# end boilerplate
# =================================================================

main


```