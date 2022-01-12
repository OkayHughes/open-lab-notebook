---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: bash.source
  parent: Singularity Container
layout: layouts/post.njk
---

```

fail() {
  echo "ctrl-f for 'fail' to find what must change"
}
# from CJ CESM install instructions:
# https://docs.google.com/document/d/1VHEWx3Isxs7csE2tv1bxtTvBkUIVU_LK_jocxjxy1Tw/edit?usp=sharing

# for E3SM
INPUT_NAME=inputData 
export MY_E3SM_ROOT=${USER}/E3SM/CLDERA-E3SM
export DIN_LOC_ROOT=${MY_E3SM_ROOT}/${INPUT_NAME}
export MY_E3SM_CASES=${USER}/E3SM/E3SMv2_cases
fail \
  && export MY_SLURM_ACCOUNT=cjablono1
fail \
  && export MY_E3SM_SCRATCH=/scratch/cjablono_root/cjablono1/owhughes/E3SM
```


