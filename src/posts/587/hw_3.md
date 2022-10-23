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


* Each thread has a maximum stack length, with length calculated based on a heuristic (prevents overdoing omp lock).
* While private stack length not longer than, use endpoints to determine maximum value `$$g(b) + g(a) + s\frac{b-a}{2} $$`
  * If not larger than `$$M+\varepsilon$$` add to deletion stack
  * If larger, then divide the interval into two and add it to the continue stack
* After processing the chunk
  * request deletion stack lock and prepend deletion stack
  * request continuation stack lock and prepend 

Useful lemma:
Suppose we have a global maximum `$$ M_1 $$`. If we wrap each thread's read of this value in an atomic 
clause, and we have a mutex-protected lock on writing `$$M_1=M_2$$` which ensures monotonicity (prove this in final code)
then if we determine that on an interval `$$[a_i, b_i]$$` our function `$$g$$` cannot be more than `$$M_1$$`, then
we also know that it cannot be more than any `$$M_i > M_1$$` determined during processing of the interval
`$$[a_i, b_i]$$`. Therefore to keep `$$M$$` consistent,
we start the processing step by reading `$$M$$` and at the end of this step we can call the thread-safe method to write `$$M$$`.



Develop library of functions and test heuristics on this library of functions