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

Modify the case creation script `~/.cime/singularity_create_aquaplanet.sh` (you can ctrl-f "fail" to see where to change things)

From within the singularity container, run the case script. After it finishes 
navigate to the `case_scripts` directory in our aquaplanet case 
and run `./case.build` again, because the build script seems to not
install all the files that need to be placed somewhere.

Once this is done, copy `~/.cime/submit.sh` to the `case_scripts` directory.

Modify this verison of `submit.sh` to match your filesystem. 

Run `sbatch submit.sh.` See if it works.







# Step 0:
* If you're on Mac, install [Docker](https://docs.docker.com/desktop/mac/install/) and create an Ubuntu image.
* Install an Ubuntu 18.04 image.
* Install singularity within this image.

The `e3sm.def` file for building the `e3sm.sif` file is given [here](https://open-lab-notebook.glitch.me/posts/E3SM/e3sm_container/)

Look up a tutorial for how to build this image using singularity within ubuntu.



