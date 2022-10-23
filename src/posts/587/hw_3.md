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


* Each thread has a maximum search depth, with depth calculated based on a heuristic (prevents overdoing omp lock).
* While , use endpoints to determine maximum value `$$g(b) + g(a) + s\frac{b-a}{2} $$`
  * If not larger than `$$M+\varepsilon$$` add to deletion stack
  * If larger, then divide the interval into two and add it to the continue stack
* After processing the chunk
  * request deletion stack lock and prepend deletion stack
  * request continuation stack lock and prepend 

