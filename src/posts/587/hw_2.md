---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: eecs587
  key: hw_2
layout: layouts/post.njk
---

Pseudocode:
Have master processor compute block decomposition.
Calculate block decomposition on local processor.
Allocate blocks + ghost cells 

Main loop:
  Communicate ghost cell values
  Calculate updated values
  