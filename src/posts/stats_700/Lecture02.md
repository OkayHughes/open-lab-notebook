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
Controlling for post-treatment variables can introduce bias to estimates of treatment effects ([Rosenbaum, 1984](https://doi.org/10.2307/2981697)).

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

## Formalizing conditions for treatment effect identification
In this section let's show why randomizing `$$Z_i$$` gives us `$$\probe[Y_i \mid Z_i=z] = \probe[Y_i(1)]$$`. This would give us `$$$\probe[Y_i(1) - Y_i(0)] = \probe[Y_i \mid Z_i=1] - \probe[Y_i \mid Z_i = 0] $$$`

There are three assumptions needed to show the above equality: **SUTVA, ignorability, and overlap**. 

### SUTVA:
The Stable Unit Treatment Value Assumption links `$$ Y_i(1)$$` and `$$Y_i(0)$$` to the observed outcome `$$Y_i$$` [Rubin 1980](https://doi.org/10.2307/2287653).
SUTVA states that 
`$$$
\begin{align*}
  Y_i &= Z_iY_i(1) + (1-Z_i)Y_i(0) 
\end{align*}
$$$`
or
`$$$
Z_i=z \implies Y_i = Y_i(z)
$$$`
which seems mathematically intuitive, but 
the validity of this assumption in the context
of real-world complexity must be assessed by 
subject-matter experts. There are two main things
that should be assessed:
* There are no hidden versions of treatment 
or that treatment variation is negligible.
This measn that if `$$Z_i=z$$`, either 1) there is only one version fpr
unit `$$i$$` to receive the treatment (or control) or b) variations in how treatment is received
do not affect potential outcomes.
  * E.g. the college example above _does not_ satisfy this assumption.
* There is _no interference_: that is, unit `$$i$$`'s treatment value `$$Z_i$$` does not impact whether another unit is treated. 
  * E.g. "being on a diet" does not satisfy assumption 1 (furthermore, even fixing a type of diet, this is violated)

Verbatim from the notes: the two articles by [Hernan and Taubman](https://www.ncbi.nlm.nih.gov/pubmed/18695657) and [Cole and Frangakis](https://journals.lww.com/epidem/fulltext/2009/01000/The_Consistency_Statement_in_Causal_Inference__A.3.aspx) provide excellent expositions on this topic. Also, check out a recent twitter thread by [Miguel](https://twitter.com/_miguelhernan/status/997298467797131265) on this topic. In summary, the Rubin (via Frangakis, goes back to this paper) and Robins (via Hernan) school of causal inference emphasize the notion of well-defined interventions to define treatment in a good causal inference study. 
In fact, because of this phenomena, there is also debate as to whether we can estimate the causal effect of race since intervening on race is impossible. There was an entire journal dedicated to defining treatments in causal inference around [2017](https://academic.oup.com/ije/search-results?f_TocHeadingTitle=Approaches%20to%20causal%20inference).

Takeaway: before you define a causal effect, think about whether the treatment is well-defined.

### Ignorability:
This is called different things in different fields.

Firstly, we state unconditional ignorability.This holds in randomized experiments, and
`$$
\{Y_i(1), Y_i(0)\} \bot Z_i
$$`
where it is important that this set is _taken together_ (otherwise our experiment would be meaningless).

In the sense of missing data, this gives us that missingness of `$$Y_i(0)$$` or `$$Y_i(1)$$` by column happens completely at random (MCAR). 
THis gets pretty mangy in observational contexts!

