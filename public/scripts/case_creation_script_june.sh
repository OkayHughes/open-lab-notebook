export CESMDATAROOT=$scratch/CESM_INPUT
readonly CESM_PREFIX="CAM_JUNE22"
readonly COMPSET="FADIAB"
readonly GRID_NAME="ne30_ne30_mg17"
readonly CESM_GROUP="test_cases"
readonly CASE_ID="jw06"
readonly NPROCS="36"

# =================
readonly CASE_DIR="${HOME}/cesm_cases/${CESM_PREFIX}/${CESM_GROUP}"
readonly SRC_DIR="${HOME}/${CESM_PREFIX}"
readonly CASE_NAME="${CESM_PREFIX}.${GRID_NAME}.${COMPSET}.${NPROCS}.${CESM_GROUP}.${CASE_ID}"
readonly BUILD_ROOT="${scratch}/CESM/${CESM_PREFIX}/${CASE_NAME}"
# =================
readonly MY_SLURM_ACCOUNT=cjablono0
readonly MY_CESM_ROOT=/scratch/cjablono_root/${MY_SLURM_ACCOUNT}/${USER}/CESM_ROOT
readonly DIN_LOC_ROOT=/scratch/cjablono_root/${MY_SLURM_ACCOUNT}/${USER}/CESM_ROOT/input
readonly MY_CESM_CASES=${CASE_DIR}
readonly MY_CESM_SRC=${SRC_DIR}
readonly ESMF_DIR=${HOME}/esmf/esmf-8.3.0/lib/libO/Linux.intel.64.openmpi.default
readonly MY_CESM_SCRATCH=/scratch/cjablono_root/${MY_SLURM_ACCOUNT}/${USER}
export PATH=${SRC_DIR}/cime/scripts/://sw/arcts/centos7/stacks/intel/18.0.5/netcdf-fortran/4.4.5/bin:/sw/arcts/centos7/stacks/intel/18.0.5/netcdf-c/4.6.2/bin:/sw/arcts/centos7/cmake/3.13.2/bin:/sw/arcts/centos7/stacks/intel/18.0.5/hdf5/1.8.21/bin:/sw/arcts/centos7/stacks/intel/18.0.5/openmpi/3.1.4/bin:/sw/arcts/centos7/intel/18.0.5/compilers_and_libraries_2018.5.274/linux/bin/intel64:/sw/med/centos7/ghostscript/9.27/bin:/sw/lsa/centos7/nco/4.7.2/bin:/sw/arcts/centos7/ncl/6.6.2/bin:/sw/lsa/centos7/ncview/2.1.8/bin:/opt/singularity/3.5.2/bin:/opt/TurboVNC/bin:/opt/slurm/bin:/opt/slurm/sbin:/usr/lib64/qt-3.3/bin:/sw/arcts/centos7/usertools/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/lpp/mmfs/bin:/opt/ibutils/bin:/opt/ddn/ime/bin
# ================


export_mach_vars() {
    export MY_CESM_ROOT
    export DIN_LOC_ROOT
    export MY_SLURM_ACCOUNT
    export MY_CESM_CASES
    export MY_CESM_SRC
    export MY_CESM_SCRATCH
    export CESM_GROUP
    export ESMF_DIR
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
    export_mach_vars
    yes r | ${SRC_DIR}/cime/scripts/create_newcase --compset "${COMPSET}" --res ${GRID_NAME} --case ${CASE_DIR}/${CASE_NAME} --run-unsupported --pecount ${NPROCS}
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

readonly STOP_N=20


readonly ATM_NCPL=96

# ------------------
# Set the frequency at which files for restarting the model (e.g. in the 
# case of a blowup) are written. If TRUE, make sure to set REST_N

readonly REST_OPTION=none
readonly REST_N=1

# ====================
# CAM build flag (note: this is quite finicky and causes compiler errors if done wrong)

readonly CAM_CONFIG_OPTS="--phys adiabatic --analytic_ic"

 #--------------------
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
 avgflag_pertape  = 'I'
 fincl1           = 'PS:I','T:I','U:I','V:I','OMEGA:I','T850:I','U850:I','V850:I','OMEGA850:I','PHIS:I'
 MFILT            = 90
 NHTFRQ       = -24
 NDENS          = 2
EOF

}



create_bash_source() {
    local config_script="$CASE_DIR/${CASE_NAME}/bash.source"
    cat << EOF > $config_script
module load intel/18.0.5
module load openmpi/3.1.4
module load netcdf-c/4.6.2
module load netcdf-fortran/4.4.5
readonly MY_CESM_ROOT=${MY_CESM_ROOT}
export MY_CESM_ROOT
readonly DIN_LOC_ROOT=${MY_CESM_ROOT}
export  DIN_LOC_ROOT
readonly MY_SLURM_ACCOUNT=${MY_SLURM_ACCOUNT}
export MY_SLURM_ACCOUNT
readonly MY_CESM_CASES=${MY_CESM_CASES}
export MY_CESM_CASES
readonly MY_CESM_SRC=${MY_CESM_SRC}
export MY_CESM_SRC
readonly MY_CESM_SCRATCH=${MY_CESM_SCRATCH}
export MY_CESM_SCRATCH
readonly ESMFMKFILE=${ESMF_DIR}/esmf.mk
export ESMFMKFILE
export PATH=${PATH}
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
    create_case \
        && create_xml_config_helper \
        && create_user_nl_cam \
        && create_preview_namelists_helper \
        && create_case_build_helper \
        && create_bash_source
    
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