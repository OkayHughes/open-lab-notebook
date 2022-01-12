---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: submit.sh
  parent: Singularity Container
layout: layouts/post.njk
---

```
#!/bin/bash
#
#SBATCH --job-name singularity_e3sm_test
#SBATCH --account=cjablono1
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1000m 
#SBATCH --time=0:60:00
#SBATCH --container=/home/owhughes/containers/singularity/e3sm.sif
#
# 25 nodes, 30min sufficient for all 5 runs
# 12 nodes, 10min for r400 an r100
# 






singularity exec /home/owhughes/containers/singularity/e3sm.sif "./case.submit"
```


