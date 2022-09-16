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
  
  
  
## First task: divide the domain
We want to be able to divide an `$$m\times n$$` matrix among
`$$p$$` processors, with minimal assumptions about divisibility.

Add outer calling routine which takes arbitrary `$$m', n'$$` and 
design inner method assuming `$$ m \geq n$$`


Divide horizontal stripes of matrix among processors. 

That is, assign `$$\lfloor \frac{m}{p} \rfloor $$` to each of the `p` processors. 
As an example, if we have 1000 rows and 16 processors, then 
we get `$$ \frac{1000}{16}= 62.5.$$` If we assign 62 rows to 
each processor then there are 8 rows left over. Therefore 

This informs the following method:

The number of excess rows is calculated by `$$m - p\lfloor \frac{m}{p} \rfloor$$`


This method will behave badly if `$$m$$` is `$$ \mathcal{O}(p) $$` but that's not the case
we're designing for. 