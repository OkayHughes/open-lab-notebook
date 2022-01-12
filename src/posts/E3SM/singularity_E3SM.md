---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Singularity Container
  parent: E3SM
layout: layouts/post.njk
---
# Quickstart:

Get the singularity image:

```
PATH_TO_IMAGE="/set/your/path/here"
cp /nfs/turbo/cjablono2/owhughes/e3sm.sif ${PATH_TO_IMAGE}
```

Run:


Run: 
```
singularity run ${PATH_TO_IMAGE} "./singularity_run_e3sm.sh"
```







# Step 0:
* If you're on Mac, install [Docker](https://docs.docker.com/desktop/mac/install/) and create an Ubuntu image.
* 




