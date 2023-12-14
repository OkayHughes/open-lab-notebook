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
P_n^m(x) = \sqrt{(2n+1) \frac{(n-m)!}{(n+m)!}} \cdot \frac{(1-x^2)^{\frac{|m|}{2}}}{2^n n!} \left(\der{^{n+|m|}}{x^{n+|m|}} (1-x^2)^n \right)
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


`$$$
P_0^0(x) = \sqrt{(0) \frac{(0)!}{(0)!}} \cdot \frac{(1-x^2)^{0}}{2^0 0!} \left(\der{^{0}}{x^0} (1-x^2)^0\right) = 1
$$$`
`$$$ P_0^1(x) = P_0^2(x) = 0    $$$`

`$$$
\begin{align*}
P_1^0(x) &= \sqrt{(2+1) \frac{(1-0)!}{(1+0)!}} \cdot \frac{(1-x^2)^{\frac{|0|}{2}}}{2^1 1!} \left(\der{^{1+|0|}}{x^{1+|0|}} (1-x^2)^1 \right) \\
&= \sqrt{3} \cdot \frac{1}{2 } \left(\der{}{x} (1-x^2)^1 \right) \\
&= \sqrt{3} \cdot \frac{1}{2} 2x  \\
&= \sqrt{3} \cdot x  \\
\end{align*}
$$$`

`$$$
\begin{align*}
P_1^1(x) &= \sqrt{(2+1) \frac{(1-1)!}{(1+1)!}} \cdot \frac{(1-x^2)^{\frac{|1|}{2}}}{2^1 1!} \left(\der{^{1+|1|}}{x^{1+|1|}} (1-x^2)^n \right) \\
    &= \sqrt{3} \cdot \sqrt{1-x^2} \frac{1}{2} \left(\der{^{2}}{x^{2}} (1-x^2) \right) \\
    &= \sqrt{3} \cdot \sqrt{1-x^2}  \\
\end{align*}
$$$`

and `$$P_1^2(x) = 0 $$`


The recurrence relation for `$$m=0$$` is `$$n P_{n}^0(x) = (2n-1)x P_{n-1}^0(x) - (n-1) P^0_{n-2}(x) $$`

