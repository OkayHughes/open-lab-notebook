---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Lecture 02
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
* `$$ \probe [Y_i(1) - Y_i(0)]$$`: the average difference in income that would happen if a student went to college.

### Being sloppy:
A naive estimator of `$$\tau$$` would be to take the difference between mean income in the population who graduated from college and those who didn't.
That is,
`$$$\hat{\tau} = \hat{\probe}[Y_i \mid Z_i = 1] - \hat{\probe}[Y_i \mid Z_i = 0] = \frac{1}{n_1} \sum_i Y_iZ_i - \frac{1}{n_0} \sum_i Y_i(1-Z_i) $$$`

Note that this should be interpreted as "the two populations of interest should differ in mean income by this amount".
This completely fails to address any sort of counterfactual reality. That people can self-select into going to college
gives us `$$\probe[Y_i(1) \mid Z_i=1] \neq \probe[Y_i(1)]$$`.

The estimands that we want are `$$\probe[Y_i(1)] - \probe[Y_i(0)]$$` which vary over _the same population of individuals_. 
Supposing this is the case, then a non-zero `$$\tau_i$$` is attributable to the treatment. But if the populations differ (as in the college case), then 
differences in the population could explain the treatment effect. 


Note: the power of randomized trials is that the distribution of both unobserved covariates `$$U_i$$` and observed covariates `$$X_i$$` are balanced between the two groups.
This can be seen in the attached notebook. While covariates like parental education are highly unbalanced when college is not randomized, the balance is nearly perfect when we fictitiously assign 
students to go to college or not.