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


