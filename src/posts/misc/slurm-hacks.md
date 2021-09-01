---
title: Some slurm hacks
date: 2021-08-31
tags:
  - posts
  - slurm
  - scientific-computing
eleventyNavigation:
  key: Some slurm hacks
  parent: Scientific Computing
layout: layouts/post.njk
---


Firstly, I've aliased the following in my local .profile: 

`alias greatlakes="ssh -Y ${USERNAME}@greatlakes.arc-ts.umich.edu"`.


### `sping`:
In order to see just the information I want to see about my current jobs, I use the alias 

`alias sping='squeue -u ${USERNAME} --format="%.18i %.60j %.2t %.10M"'`

### `ijob`
In order to create an interactive job with a certain number of processors and a certain amount of time, I do

```
function ijob {
NCPU=${2:-8}
MEM=${3:-2000}
TIME=${4:-1}
srun --job-name "$1" --cpus-per-task $NCPU --mem-per-cpu $MEM --time ${TIME}:00:00 --pty bash
}
```

The default is to create a job with 8 processors (i.e. virtual processors). 
The memory is 2 GB per cpu, and the time is 1 hour.








