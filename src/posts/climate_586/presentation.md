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


They state that `$$P_n^m(x) = P_n^{-m}(x) $$`, which may be slightly wrong depending on normalization?
In any case `$$P_n^m (x) = 0 $$` if `$$|m| > n$$`. 

They recommend a special recurrence relation
`$$$
\begin{align*}
  P_n^m(x) &= c_n^m P_{n-2}^{m-2}(x) - d_n^m x P_{n-1}^{m-2}(x) + e_n^m P_{n-1}^m (x) \\
  c_n^m &\equiv \sqrt{\frac{2n+1}{2n-3} \cdot \frac{m+n-1}{m+n} \cdot \frac{m+n-3}{m+n-2}} \\
  d_n^m &\equiv \sqrt{\frac{2n+1}{2n-1} \cdot \frac{m+n-1}{m+n} \cdot \frac{n-m+1}{m+n-2}} \\
  e_n^m &\equiv \sqrt{\frac{2n+1}{2n-1} \cdot \frac{n-m}{n+m}}
\end{align*}
$$$`
for `$$ m > 0.$$` When `$$m=0$$`, we can use the fact that the Legendre and Associated Legendre polynomials coincide.

# starting induction:

## 