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
#!/bin/sh
readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

main() {
    local dir="/glade/scratch/${USER}/trash/$(date '+%Y/%m/%d/%H_%M')"
    mkdir -p $dir \
        && mv ${ARGS} ${dir} \
        && echo "Files moved to ${dir}"

}


main
```
  
</details>



Run `chmod +x ~/.local/bin/move_to_trash.sh,`

add `alias trash="~/.local/bin/move_to_trash.sh"` to `.bashrc`










