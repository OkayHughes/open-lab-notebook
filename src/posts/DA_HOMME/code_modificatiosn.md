---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Code modifications
layout: layouts/post.njk
---

# Finding and modifying the vertical integral
The idea is to do this by modifying the underlying subroutine. Hopefully one exists.
Geopotential used in NH model: called `phinh_i` (only at interfaces). 

In order to calculate a vertical integral, either `phinh_i` or `dp3d` must be referenced.

So: plan for tomorrow. 
0) Ensure deep atmosphere 2016 base state is available.  (Looks to be true!)
1) Modify EOS + elem ops following MT document
2) Identify as many vertical integrals as possible. Figure out how to change them.




# Step 1: calcuate `$$ \hat{r}$$` on interfaces, model levels



# Step 2: Modify `dp3d` calculation to deep atmosphere form.



# Step 3: Modify EOS calculations 


# Step 4: Misc


# Step 5: BW test

