---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: eecs587
  key: hw_3
layout: layouts/post.njk
---

Use depth first search using example code provided in section to design a 
stack.


* Each thread has a chunk of nodes, with chunk calculated based on a heuristic (prevents overdoing omp lock).
* For each interval data, use endpoints to determine maximum value `$$\max\left(a + s\frac{b-a}{2}, b + s\frac{b-a}{2} \right) $$`
  * If larger than maximum value and `$$ $$`
