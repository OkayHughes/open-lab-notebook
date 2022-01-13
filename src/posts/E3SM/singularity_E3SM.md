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
Go through Joe's installation process. 


Install the `mpich` mpi library, see e.g. [here](https://open-lab-notebook.glitch.me/posts/installing-mpas/)



Get the singularity image:

```
PATH_TO_IMAGE="/set/your/path/here"
cp /nfs/turbo/cjablono2/owhughes/e3sm.sif ${PATH_TO_IMAGE}
```

Clone [this repo](https://github.com/OkayHughes/cime.e3sm.singularity)

Run: 
```
singularity shell ${PATH_TO_IMAGE} 
source 
```









# Step 0:
* If you're on Mac, install [Docker](https://docs.docker.com/desktop/mac/install/) and create an Ubuntu image.
* 




