---
date: 2021-08-16
tags:
  - posts
  - ncl
eleventyNavigation:
  key: Presentation
  parent: CLaSP 586
layout: layouts/post.njk
---

Link [here](https://docs.google.com/presentation/d/16Y10qqQ8bAzxJQRtAox7G5Aip5Gc8oYP3UQZvvEY6JE/edit?usp=sharing)

Notes on project:

using info found [here](https://www.ecmwf.int/sites/default/files/elibrary/1983/10253-spectral-technique.pdf),
I derive a numerically stable way to compute `$$P_n^m(x)$$` for integral `$$n, m$$`.

They define the associated legendre polynomials by the Rodriguez formula
`$$$
P_n^m(x) = \sqrt{(2n+1) \frac{(n-m)!}{(n+m)!}} \cdot \frac{(1-x)^{\frac{|m|}{2}}}{2^n n!} \left(\der{^{n+|m|}}{x^{n+|m|}} (1-x^2)^n \right)
$$$`


They state that `$$P_n^m(x) = P_n^{-m}(x) $$`, which doesn