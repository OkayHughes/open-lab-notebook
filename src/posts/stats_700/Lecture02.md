---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Lecture 01
  parent: STATS 700
layout: layouts/post.njk
---
The code segments are translated to python in [this notebook](https://colab.research.google.com/drive/1iyE_oaHFu0hGqDPLCe5DoEJOzPp6CHRO?usp=sharing).

Let `$$ Z_i$$` denote the treatment assignment and `$$ Y_i$$` denote the observed outcome for unit `$$ i$$`.
We denote pre-treatment covariates by `$$ X_i$$`. These should be measured before the treatment is measured. 
Controlling for post-treatment variables can introduce bias to estimates of treatment effects ([Rosenbaum, 1984](https://www.jstor.org/stable/2981697)).

For the example of college and earnings, we define
* `$$ Z_i $$`: whether you graduated from 4-year college `($$Z_i=1$$`) or not (`$$Z_i=0$$`) in 1964.
* `$$Y_i$$`: income (in dollars) for the year 1973
* `$$X_i$$`: student `$$i$$`'s high school characteristics, family economic status, sex. These were measured in the junior/senior year of high school.

For each unit `$$1 \leq i \leq n$$` we observe `$$(X_i Z_i, Y_i) $$`

We can formulate causality by defining:
* `$$Y_i(1)$$`: income of student `$$ i$$` in 1973 if they graduated from college
* `$$Y_i(0)$$`: income of student `$$ i $$` in 1973 if they did not graduate from college
* `$$\tau_i = Y_i(1) - Y_i(0)$$`: the difference in income if student `$$i$$` graduated from college
* `$$ \probe [Y_i(1) - Y_i(0)]$$`: 