---
title: A quick to set up trash alias for bash
date: 2021-08-31
tags:
  - posts
  - slurm
  - scientific-computing
eleventyNavigation:
  key: Defensive Bash Boilerplate
  parent: Scientific Computing
layout: layouts/post.njk
---


```
readonly EXAMPLE_VAR="example_val"


write_file() {
    local config_script="$1"
    cat << EOF > $config_script
Sample File

EOF

}



main() {
    command_1 \
        && command_2 \
        && command_3

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
  











