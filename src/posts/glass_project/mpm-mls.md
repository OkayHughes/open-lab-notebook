---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Outline of MPM strategy
  key: Rewriting the equations
layout: layouts/post.njk
---

# PolyPIC:

Suppose we have `$$ x_p^n$$` for `$$n=1,\ldots,N$$` 
and an evenly-spaced Eulerian grid `$$ x_{i} $$`.
Then associated with each (fixed) particle are a set of interaction weights
`$$ w_p^{i,n}$$` that describe contribution of the value of a quantity `$$q^n_p$$`
stored at the particle position.
In typical MPM literature this is given by 
`$$$ N(x) = \begin{cases} \frac{1}{2} |x|^3 - x^2 + \frac{2}{3}, & 0 \leq |x| < 1 \\ -\frac{1}{6} |x|^3+ x^2 - 2|x| + \frac{4}{3} & 1 \leq |x| < 2 \\ 0 & \textrm{otherwise}\end{cases}$$$`
and `$$N_i(x) = N(\frac{1}{h} \left(x_1 - ih \right)) N(\frac{1}{h} \left(x_2 - jh \right)) N(\frac{1}{h} \left(x_3 - kh \right))  $$`
which bounds the 

