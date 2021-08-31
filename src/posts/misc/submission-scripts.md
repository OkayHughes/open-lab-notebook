---
title: Efficiently allocating resources in sbatch scripts
date: 2021-08-31
tags:
  - posts
  - slurm
  - scientific-computing
layout: layouts/post.njk

---


Something that trips me up literally every time I write my own submissions scripts is slurm's method of allocation.

If I later find the resources that I used to get to this understanding, I'll come back and put them here.\

### An example submission script:

This is the job submission file taken from my HOMME-E3SM custom install on greatlakes. 

```
#!/bin/bash
#
#SBATCH --job-name ${JOBNAME}
#SBATCH --account=cjablono1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=1000m 
#SBATCH --time=0:60:00
#
# 25 nodes, 30min sufficient for all 5 runs
# 12 nodes, 10min for r400 an r100
# 

source /home/owhughes/HOMME/E3SM/setup.sh
export OMP_NUM_THREADS=6
export MV2_ENABLE_AFFINITY=0
NCPU=36
EXEC=../../../test_execs/theta-l-nlev30/theta-l-nlev30



function run { 
local NCPU=$1
echo "NCPU = $NCPU"
namelist=namelist-$prefix.nl
\cp -f $namelist input.nl
date
mpirun -bind-to=core -np 36 $EXEC < input.nl
date

ncl plot-baroclinicwave-init.ncl
ncl plot-lat-lon-TPLSPS.ncl 'var_choice=1'
ncl plot-lat-lon-TPLSPS.ncl 'var_choice=2'
ncl plot-lat-lon-TPLSPS.ncl 'var_choice=3'
\mv -f plot_baroclinicwave_init.pdf  ${prefix}_init.pdf
\mv -f preqx-test16-1latlonT850.pdf  ${prefix}_T850.pdf
\mv -f preqx-test16-1latlonPS.pdf  ${prefix}_PS.pdf
\mv -f preqx-test16-1latlonPRECL.pdf  ${prefix}_PRECL.pdf

\mv -f movies/dcmip2016_test11.nc    movies/${prefix}_dcmip2016_test11.nc
}

prefix=r400    ; run $(($NCPU>384?384:NCPU))

prefix=r100-dry; run $NCPU
prefix=r100-h  ; run $NCPU
prefix=r100    ; run $NCPU

prefix=r50    ; run $NCPU

```



As far as I can tell this indicates that `ntasks-per-node` dictates the number of tasks that can be directly spawned by 
mpirun. `-bind-to=core` seems to play better with hyperthreaded processors? THIS IS THE IMPORTANT ONE!

However, one can increase `$OMP_NUM_THREADS` seemingly _ad infinitum_ without it complaining; seemingly it can support more than
36 threads at a time on one node. (Note: I haven't directly checked that it's allocating only one node to my job).

However, this appears to be the correct approach to allocating resources as all jobs from ne4 up to ne60 seem to run reasonably fast.


Note: When `-bind-to=core` is applied to MPAS, it runs in a much more sensible time frame and complains less. My guess
is that the default is that it tries to bind to a socket, and that causes it to hang, or at least eat up an absurdly wasteful 
amount of resources.

### `seff ${JOBID}`
Evidently you can do `seff ${JOBID}` 
