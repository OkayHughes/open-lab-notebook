---
title: Using globus to access locker files  
date: 2021-08-31
tags:
  - posts
  - slurm
  - scientific-computing
eleventyNavigation:
  key: An Easy-to-implement Numerical Recipe for Computing Spherical Harmonics
  parent: Scientific Computing
layout: layouts/post.njk
---

## Background:

The calculation of high-order spherical harmonics ([e.g.](https://climatedataguide.ucar.edu/climate-tools/common-spectral-model-grid-resolutions) up to `$$n=388$$`)
remains relevant to model development and data analysis in the geosciences. 
However, I recently discovered that if one is working in a language that lacks built-in functions for computing
spherical harmonics, there appears to be no succinct summary of how to calculate these functions yourself in a numerically stable way.
In implementations such as Python's `scipy`, functions such as `special.sph_harm` obscure the fact that 
there is a recursion beneath the hood. Therefore, calculation of e.g.  `$$Y_n^m(\lambda, \phi)$$`



## Mathematical Statement

using info found [here](https://www.ecmwf.int/sites/default/files/elibrary/1983/10253-spectral-technique.pdf),
I derive a numerically stable way to compute `$$P_n^m(x)$$` for integral `$$n, m$$`.

They define the associated legendre polynomials by the Rodriguez formula
`$$$
P_n^m(x) = \sqrt{\frac{(2n+1)}{2} \frac{(n-m)!}{(n+m)!}} \cdot \frac{(1-x^2)^{\frac{|m|}{2}}}{2^n n!} \left(\der{^{n+|m|}}{x^{n+|m|}} (1-x^2)^n \right)
$$$`


They state that `$$P_n^m(x) = P_n^{-m}(x) $$`, which may be slightly wrong depending on normalization?
In any case `$$P_n^m (x) = 0 $$` if `$$|m| > n$$`. 

They recommend a special recurrence relation
`$$$
\begin{align*}
  P_n^m(x) &= c_n^m P_{n-2}^{m-2}(x) - d_n^m x P_{n-1}^{m-2}(x) + e_n^m x P_{n-1}^m (x) \\
  c_n^m &\equiv \sqrt{\frac{2n+1}{2n-3} \cdot \frac{m+n-1}{m+n} \cdot \frac{m+n-3}{m+n-2}} \\
  d_n^m &\equiv \sqrt{\frac{2n+1}{2n-1} \cdot \frac{m+n-1}{m+n} \cdot \frac{n-m+1}{m+n-2}} \\
  e_n^m &\equiv \sqrt{\frac{2n+1}{2n-1} \cdot \frac{n-m}{n+m}}
\end{align*}
$$$`
for `$$ m > 0.$$` When `$$m=0$$`, we can use the fact that the Legendre and Associated Legendre polynomials coincide.



`$$$
P_0^0(x) = \sqrt{(0) \frac{(0)!}{(0)!}} \cdot \frac{(1-x^2)^{0}}{2^0 0!} \left(\der{^{0}}{x^0} (1-x^2)^0\right) = 1
$$$`
`$$$ P_0^1(x) = P_0^2(x) = 0    $$$`

`$$$
\begin{align*}
P_1^0(x) &= \sqrt{(2+1) \frac{(1-0)!}{(1+0)!}} \cdot \frac{(1-x^2)^{\frac{|0|}{2}}}{2^1 1!} \left(\der{^{1+|0|}}{x^{1+|0|}} (1-x^2)^1 \right) \\
&= \sqrt{3} \cdot \frac{1}{2 } \left(\der{}{x} (1-x^2)^1 \right) \\
&= -\sqrt{3} \cdot \frac{1}{2} 2x  \\
&= -\sqrt{3} \cdot x  \\
\end{align*}
$$$`

`$$$
\begin{align*}
P_1^1(x) &= \sqrt{(2+1) \frac{(1-1)!}{(1+1)!}} \cdot \frac{(1-x^2)^{\frac{|1|}{2}}}{2^1 1!} \left(\der{^{1+|1|}}{x^{1+|1|}} (1-x^2)^n \right) \\
    &= -\sqrt{3} \cdot \sqrt{1-x^2} \frac{1}{2} \left(\der{^{2}}{x^{2}} (1-x^2) \right) \\
    &= -\sqrt{3} \cdot \sqrt{1-x^2}  \\
\end{align*}
$$$`

and `$$P_1^2(x) = 0 $$`


The recurrence relation for `$$m=0$$` is `$$n P_{n}^0(x) = (2n-1)x P_{n-1}^0(x) - (n-1) P^0_{n-2}(x) $$`


## A simple python implementation




