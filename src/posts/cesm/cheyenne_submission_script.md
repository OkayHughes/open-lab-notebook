---
date: 2021-09-01
tags:
  - posts
  - regridding
eleventyNavigation:
  key: Cheyenne Submission Script
  parent: Community Earth System Model lifehacks
layout: layouts/post.njk
---



```
readonly CESM_PREFIX="CAM_Jan22"
readonly COMPSET="FADIAB"
readonly GRID_NAME="f09_f09_mg17"
readonly GROUP_NAME="quickstart"
readonly CASE_ID="bw_dry_jw06"
readonly PROJECT="UMIC0087"
readonly NPROCS="36"

# =================
readonly CASE_DIR="${HOME}/cesm_cases/${CESM_PREFIX}/${GROUP_NAME}"
readonly SRC_DIR="${HOME}/cesm_src"
readonly CASE_NAME="${CESM_PREFIX}.${GRID_NAME}.${COMPSET}.${GROUP_NAME}.${CASE_ID}"
readonly BUILD_ROOT="/glade/scratch/${USER}/$CASE_NAME}"
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
    yes r | ${SRC_DIR}/cime/scripts/create_newcase --compset ${COMPSET} --res ${GRID_NAME} --case ${CASE_DIR}/${CASE_NAME} --run-unsupported --project ${PROJECT} --pecount ${NPROCS}
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

readonly STOP_OPTION=ndays

# ------------------

readonly STOP_N=15

# ------------------
# Set the frequency at which files for restarting the model (e.g. in the 
# case of a blowup) are written. If TRUE, make sure to set REST_N

readonly REST_OPTION=none  

# ====================
# CAM build flag (note: this is quite finicky and causes compiler errors if done wrong)

readonly CAM_CONFIG_OPTS="--phys adiabatic --analytic_ic"

# --------------------
# Maximum runtime:

readonly HOURS=00
readonly MINUTES=10
readonly SECONDS=00

# --------------------

main() {
    ./xmlchange DEBUG=\${DEBUG},DOUT_S=\${DOUT_S},STOP_OPTION=\${STOP_OPTION},STOP_N=\${STOP_N},REST_OPTION=\${REST_OPTION} \
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
    analytic_ic_type = 'dry_baroclinic_wave_jw2006'
    empty_htapes     = .TRUE.
    avgflag_pertape  = 'I'
    fincl1           = 'PS:I','T:I','U:I','V:I','OMEGA:I','T850:I','U850:I','V850:I','OMEGA850:I','PHIS:I','PSL:I'
    MFILT            = 90
    NHTFRQ           = -24
    NDENS            = 2
    fv_nsplit        = 10 
    fv_div24del2flag = 4

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

