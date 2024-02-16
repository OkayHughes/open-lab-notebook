---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Sampling and Monte Carlo
  parent: AEROSP 567
layout: layouts/post.njk
---

## Framing: Monte Carlo

Suppose we have `$$X_1, \ldots, X_n$$` i.i.d. and let `$$g(x)$$` be a function, where we
want to estimate `$$ \probe_X[g(x)]$$`. 

Define the auxiliary variable
`$$$
S_n[g] = \frac{1}{n} \sum_{i=1}^n g(X_i)
$$$`

The frequentist estimator given `$$[X_i]$$` samples with `$$X_i \sim X$$` and `$$n$$` fixed,
`$$$ \hat{g} = \frac{1}{n} \sum_{i=1}^n g(X_i).$$$`
We can observe immediately that
`$$$
\begin{align*}
  \probe_X[S_n[g]] = \probe_X\left[ \frac{1}{n}\sum_{i=1}^n g(X_i) \right] = \frac{\sum_{i=1}^n \probe_X[g(X_i)]}{n} = \probe_X[g(x)]
\end{align*}
$$$
`
and so this estimator is unbiased. 
The variance is then
`$$$
  \probv_X[S_n[g]] = \probv_X\left[ \frac{1}{n}\sum_{i=1}^n g(X_i) \right] = \frac{1}{n^2} \sum_{i=1}^n \probv_X\left[ g(x)\right]  = \frac{1}{n} \probv_X\left[g(x) \right].
$$$`
In dimensional problems, the variance of this estimator has units of `$$g(x)^2$$`, so taking the square root of the resultant quantity (thereby giving the standard error)
shows that error tends to decrease as `$$n^{-1/2}$$`.

## Convergence of RVs






