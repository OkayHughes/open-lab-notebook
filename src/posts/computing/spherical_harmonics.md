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
there is a recursion beneath the hood. Therefore, calculation of e.g. the `$$(m,n)$$`th spherical harmonic,`$$Y_n^m(\lambda, \phi)$$`,
necessitates calculating `$$Y_{n'}^{m'}$$` for some some set of `$$(m', n')$$` for `$$m' \leq m$$`, `$$n' \leq m$$`.

The purpose of this document is to describe a simple, easy to implement, numerically stable algorithm for performing this
recursion to compute `$$Y_{n}^m$$` for `$$m,n \in \mathbb{Z}$$` in a codebase where you do not have access to an off-the-shelf library for doing so. 
The crux of what makes this difficult is calculating the so-called associated Legendre polynomials `$$P_n^m(\sin(\phi))$$`. 
If you need more esoteric computations, such as calculating `$$P_{n}^m$$` for `$$n, m \in \mathbb{R}$$`, or where use of recursion is unacceptable,
I recommend persuing a method like the one advanced in [Bremer (2017)](https://arxiv.org/abs/1707.03287). However, this method is 
significantly more complicated to implement. Furthermore, computation must be performed offline and read into memory or included as data in the executable.
The author precomputes the necessary lookup tables for `$$|\mu| \leq \nu < 10^6.$$` However, the required data are 138MB in size,
almost all of which is entirely extraneous for applications where only integral `$$m, n$$` are required.


## Mathematical Statement

We use the convention that `$$\phi\in [-\pi/2,\pi/2]$$` denotes latitude.
The Integrated Forecast System of the European Center for Numerical Range Weather Forecasting is built atop
a global spectral decomposition and can be run down to a grid spacing of 9 km.
It's therefore not surprising that they provide a recipe for calculating spherical harmonics 
which can achieve numerical stability for large `$$n$$` (though quad precision must be used for `$$n>100$$`).
Although a reasonably readable summary is provided [here](https://web.archive.org/web/20231219172924/https://www.ecmwf.int/sites/default/files/elibrary/1983/10253-spectral-technique.pdf),
this summary contains several crucial errors. I therefore follow their derivation and note corrections where I make them.

There are several ways of normalizing the associated Legendre polynomials. The choice used here is that the un-normalized
associated Legendre polynomial `$$\tilde{P}_n^m$$` is multiplied by
`$$$
\sqrt{(2n+1)\frac{(n-m)!}{(n+m)!}} 
$$$`
to obtain the normalized associated Legendre polynomials `$$P_n^m $$`. One advantage of this normalization
is that `$$P_n^{-m} = (-1)^m P_n^m$$` (this is mis-stated in the ECMWF document)
, omitting the factorial term that arises in the un-normalized associated Legendre polynomials.

To start the recursion we use the definition of the associated Legendre polynomials given by the Rodriguez formula
`$$$
P_n^m(x) = \sqrt{(2n+1)\frac{(n-m)!}{(n+m)!}} \cdot \frac{(1-x^2)^{\frac{|m|}{2}}}{2^n n!} \left(\der{^{n+|m|}}{x^{n+|m|}} (1-x^2)^n \right).
$$$`
As a consequence of this definition, if `$$|m| > |n|$$`, then
the derivative term vanishes and `$$P_n^m (x) = 0 $$`. 

The ECMWF document recommend a special recurrence relation
`$$$
\begin{align*}
  P_n^m(x) &= c_n^m P_{n-2}^{m-2}(x) - d_n^m x P_{n-1}^{m-2}(x) + e_n^m \textcolor{red}{x} P_{n-1}^m (x) \\
  c_n^m &\equiv \sqrt{\frac{2n+1}{2n-3} \cdot \frac{m+n-1}{m+n} \cdot \frac{m+n-3}{m+n-2}} \\
  d_n^m &\equiv \sqrt{\frac{2n+1}{2n-1} \cdot \frac{m+n-1}{m+n} \cdot \frac{n-m+1}{m+n-2}} \\
  e_n^m &\equiv \sqrt{\frac{2n+1}{2n-1} \cdot \frac{n-m}{n+m}}
\end{align*}
$$$`
for `$$ m > 0.$$` The red `$$\textcolor{red}{x}$$` is a crucial correction of a typo in the reference document. When `$$m=0$$`, we can use the fact that the Legendre and Associated Legendre polynomials coincide.
The recurrence relation for `$$m=0$$` is `$$n P_{n}^0(x) = (2n-1)x P_{n-1}^0(x) - (n-1) P^0_{n-2}(x) $$`.

### Initializing the recursion

`$$$
P_0^0(x) = \sqrt{(0) \frac{(0)!}{(0)!}} \cdot \frac{(1-x^2)^{0}}{2^0 0!} \left(\der{^{0}}{x^0} (1-x^2)^0\right) = 1
$$$`
`$$$ P_0^1(x) = P_0^2(x) = 0    $$$`

`$$$
\begin{align*}
P_1^0(x) &= \sqrt{(2+1) \frac{(1-0)!}{(1+0)!}} \cdot \frac{(1-x^2)^{\frac{|0|}{2}}}{2^1 1!} \left(\der{^{1+|0|}}{x^{1+|0|}} (1-x^2)^1 \right) \\
&= \sqrt{3} \cdot \frac{1}{2 } \left(\der{}{x} (1-x^2)^1 \right) \\
&= -\sqrt{3} \cdot -\frac{1}{2} 2x  \\
&= \sqrt{3} \cdot x  \\
\end{align*}
$$$`

`$$$
\begin{align*}
P_1^1(x) &= \sqrt{(2+1) \frac{(1-1)!}{(1+1)!}} \cdot \frac{(1-x^2)^{\frac{|1|}{2}}}{2^1 1!} \left(\der{^{1+|1|}}{x^{1+|1|}} (1-x^2)^n \right) \\
    &= -\sqrt{3} \cdot \sqrt{1-x^2} \frac{1}{2} \left(\der{^{2}}{x^{2}} (1-x^2) \right) \\
    &= -\sqrt{3} \cdot \sqrt{1-x^2}  \\
\end{align*}
$$$`

and `$$P_1^2(x) = 0 $$`.

### Algorithm pseudocode
For `$$N$$` the maximum total wavenumber (i.e. `$$ |m| \leq n \leq N$$`) and a single point `$$(\lambda, \phi)$$`, 
allocate a `$$(3, N)$$` array with zeros. The component `$$(0, m)$$` is the associated legendre polynomial
`$$P_{n-2}^m$$` and `$$(1, m)$$` is `$$P_{n-1}^m$$`. We will not store `$$P_{n}^{-m}$$` but rather compute it when needed.

* Initialize `$$P_n^m$$` for `$$(n, m) \in \{(0, 0), (1, 0), (0, 1)\}$$` using the above analytic equations
* For `$$n=2,N$$` do
  a
  * b
* `done`






## A simple python implementation

```
def n_m_to_d(n,m):
  return int(n**2 + n + m)

def assoc_leg_to_sph_harm(p, lon, m):
    pronk = np.exp(1j * m * lon) * p / np.sqrt(4*np.pi)
    return pronk

def assoc_leg_m_n(lat, lon, out, example_fn):
  # ==================
  # lat, lon are given in radians
  # out returns spherical harmonic evaluations at provided points
  # example_fn(Y_n_m, n, m) takes 
  #    * Y_n_m: an array of spherical harmonic evaluations
  #    * n, m: the order and total wavenumber of Y_m_n
  # ===================
  x = np.sin(lat)

  p_prev = np.zeros((3, n_max, x.size))

  p_prev[0, 0, :] =  np.ones_like(x) # P_0^0 = 1
  out[n_m_to_d(0,0),:] = assoc_leg_to_sph_harm(p_prev[0,0,:], lon, 0)
  example_fn(out[n_m_to_d(0,0),:], 0, 0)


  p_prev[1, 0, :] = np.sqrt(3) * x # P_1^0 = \sqrt{3} x
  out[n_m_to_d(1,0),:] = assoc_leg_to_sph_harm(p_prev[1,0,:], lon, 0)
  example_fn(out[n_m_to_d(1,0),:], 1, 0)
  p_prev[1, 1, :] = -np.sqrt(3/2) * np.sqrt(1 - x**2)# P_1^1 = \sqrt{\frac{3}{2}(1-x^2)}
  out[n_m_to_d(1,1),:] = assoc_leg_to_sph_harm(p_prev[1,1,:], lon, 1)
  out[n_m_to_d(1,-1),:] = -1 * assoc_leg_to_sph_harm(p_prev[1,1,:], lon, -1)
  example_fn(out[n_m_to_d(1,1),:], 1, 1)
  example_fn(out[n_m_to_d(1,-1),:], 1, -1)

  for n in range(2, n_max):
    p_prev[2, 0, :] = np.sqrt(2 *n  + 1 )/n * ((2 * n -1 ) * x * (p_prev[1, 0, :]/np.sqrt(2*(n-1)+1)) - (n-1) * (p_prev[0, 0, :]/np.sqrt(2 * (n-2) + 1)) )
    out[n_m_to_d(n,0),:] = assoc_leg_to_sph_harm(p_prev[2,0,:], lon, 0)
    example_fn(out[n_m_to_d(2,0),:], 2, 0)
    for m in range(1, n+1):
      mm2 = abs(m-2)
      m_neg = (-1)**m if m-2 < 0 else 1
      c_mn = np.sqrt(((2*n+1)/(2*n-3)) * ((m + n - 1)/(m + n)) * ((m + n - 3)/(m + n - 2)))
      d_mn = np.sqrt(((2*n+1)/(2*n-1)) * ((m + n - 1)/(m + n)) * ((n-m + 1)/(m + n - 2)))
      e_mn = np.sqrt(((2*n+1)/(2*n-1))* ((n-m)/(n+m)))
      p_nm2_mm2 = m_neg * p_prev[0, mm2, :]
      p_nm1_mm2 = m_neg * p_prev[1, mm2, :]
      p_nm1_m = p_prev[1, m, :]
      p_prev[2, m, :] = c_mn * p_nm2_mm2 - d_mn * x * p_nm1_mm2 + e_mn *x * p_nm1_m
      out[n_m_to_d(n,m),:] = assoc_leg_to_sph_harm(p_prev[2,m,:], lon, m)
      out[n_m_to_d(n,-m),:] = (-1)**m * assoc_leg_to_sph_harm(p_prev[2,m,:], lon, -m)
      example_fn(out[n_m_to_d(n,m),:], n, m)
       example_fn(out[n_m_to_d(n,-m),:], n, -m)
    p_prev[0, :, :] = p_prev[1, :, :]
    p_prev[1, :, :] = p_prev[2, :, :]
    p_prev[2, :, :] = 0
```


