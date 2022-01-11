---
title: A quick to set up trash alias for bash
date: 2021-08-31
tags:
  - posts
  - slurm
  - scientific-computing
eleventyNavigation:
  key: A quick to set up trash alias for bash
  parent: Scientific Computing
layout: layouts/post.njk
---

Create the following script

<details>
<summary>~/.local/bin/move_to_trash.sh</summary>

```
readonly EXAMPLE_VAR="example_val"








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
  
</details>











