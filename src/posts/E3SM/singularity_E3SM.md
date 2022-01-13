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
Go through [Joe's installation process](https://github.com/jhollowed/e3sm_greatlakes_install). 


Install the `mpich` mpi library, see e.g. [here](https://open-lab-notebook.glitch.me/posts/installing-mpas/)


Load the singularity module:
```
module load singularity
```

Get the singularity image:

```
PATH_TO_IMAGE="/set/your/path/here"
cp /nfs/turbo/cjablono2/owhughes/e3sm.sif ${PATH_TO_IMAGE}
```

Clone [this repo](https://github.com/OkayHughes/cime.e3sm.singularity) into `~/.cime`.

Modify `~/.cime/bash.source` to match your setup.

Run: 
```
singularity shell ${PATH_TO_IMAGE} 
source ~/.cime/bash.source
```

Modify the case creation script `~/.cime/` (you can ctrl-f "fail" to see where to change things)








# Step 0:
* If you're on Mac, install [Docker](https://docs.docker.com/desktop/mac/install/) and create an Ubuntu image.
* 




