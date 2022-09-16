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

That is, assign `$$\lfloor \frac{m}{p} \rfloor $$` to each of the `$$p$$` processors. 
Because we are designing this algorithm for `$$p < \frac{\min(m', n')}{10} = \frac{1}{10}n $$` processors,
we therefore know that `$$ \frac{m}{p} \geq \frac{n}{p} > 10.$$` 


As an example, if we have 1000 rows and 16 processors, then 
we get `$$ \frac{1000}{16}= 62.5.$$` If we assign 62 rows to 
each processor then there are 8 rows left over. We know automatically that
the number of leftover rows is less than or equal to the total number of blocks.

This informs the following method of calculating responsibility of a row:
```
start_idx = 0
end_idx = None
base_rows_per_block = np.floor(NROWS/NPROCS)
remainder = NROWS - base_rows_per_block * NPROCS
for rank_idx in range(my_rank):
  if remainder > 0:
    else
```


The number of excess rows is calculated by `$$m - p\lfloor \frac{m}{p} \rfloor$$`


This method will behave badly if `$$m$$` is `$$ \mathcal{O}(p) $$` but that's not the case
we're designing for. 