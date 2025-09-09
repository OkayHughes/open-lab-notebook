---
date: 2023-11-06
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Training data
  key: Generating advection data
layout: layouts/post.njk
---

I've been thinking about how to generate good training data for a superresolution advection model that takes a low-res pair `$$u(x), a(x)$$` and returns a 4x enhanced
pair. To me this seems like a good testbed to start thinking about how to enforce physical constraints on neural networks, or to experiment with spatial confidence masks.

To start with, I want to be able to randomly sample wind fields that are complex enough to be interesting, but not so complex that they're gobbledegook.

Note: all the indexes here are provided without warranty. Off by one errors galore.

## Uniform sample of polynomials with `$$\| p \|_2 = 1 $$`

If we associate the legendre polynomials `$$\ell_k$$` with `$$ \mathbb{R}^n$$`, then we can generate a uniform distribution over the sphere
as `$$ \boldsymbol{z} = \frac{\boldsymbol{z}'}{\|\boldsymbol{z}'\|} $$` with `$$\boldsymbol{z}' = (z'_1, \ldots, z'_n) $$`, `$$ z'_k \sim \mathcal{N}(0, 1)$$`. If we let
`$$ p(x) = \sum_k z_k \ell_k(x)$$`, then `$$$ \int p^2 \intd{x} = \sum_{k,l} z_k z_l \int p_k(x) p_l(x) \intd{x} = \sum_k z_k^2 = 1 $$$`.

The better choice of orthogonal functions for our data generation purposes are the trigonometric polynomials.
## Constant total variation
The total variation of a function can be calculated as `$$ \sup_{\mathcal{P}} \sum_{i=0}^{n_\mathcal{P}-1} |f(x_{i+1})| - |f(x_i)|$$`, where `$$ \mathcal{P}$$` are partitions of
some interval `$$I = [a, b]$$`. A function has bounded variation if and only if it can be written as the difference of two functions `$$ f = f_1 - f_2$$` which are each non-decreasing.

In order to sample functions of constant bounded variation, assume that we have a fixed set of sample grid points on an interval, `$$ x_i$$`.
For simplicity, we can just assume that we have jump discontinuities and that the functions we're constructing are left continuous, with jump discontinuities at our `$$ x_i $$`.
To construct non-decreasing functions, we can sample `$$ z_k^{\textrm{inc/dec}} $$` from some distribution which only has support on the non-negative reals, then take `$$ f_1(x_i) = \sum_{k=0}^i z_k^{\textrm{inc}} $$`.

Then `$$$ 
\begin{align*}
 \sup_{\mathcal{P}} \sum_{i=0}^{n_\mathcal{P}-1} |f(x_{i+1})| - |f(x_i)| &= \sum_{i=0}^{N} |f(x_{i+1}) - f(x_i)|  \\
    &=  \sum_{i=0}^{N} \left|\sum_{k=0}^{i+1} \left(z_k^{\textrm{inc}} - z_k^{\textrm{dec}}  \right)  - \sum_{k=0}^{i} \left(z_k^{\textrm{inc}} - z_k^{\textrm{dec}}  \right) \right| \\
    &=  \sum_{i=0}^{N} \left|z_{i+1}^{\textrm{inc}} - z_{i+1}^{\textrm{dec}} \right| \\
\end{align*}
$$$`
Therefore, to sample from functions with total variation `$$ T $$`, sample points `$$ d_k \in [0, T] $$` and order them `$$ d_1 \leq \ldots, \leq d_N$$`, where `$$|z_{i+1}^{\textrm{inc}} - z_{i+1}| = d_{i+1} - d_i $$`, and sample signs `$$ s_i \in [-1, 1]$$`, and let `$$ f_k(x_i) = \sum_k s_k (d_{k+1} - d_k) $$`.

## Next steps:
* Use 1d Riemann-solver-free code to generate advection solutions for 100 wind profiles, 100 initial conditions. 
* Determine corect method to normalize training data
* Design snapshot superrresolution architecture, examine characteristics of solutions
* Design n-leadtime superresolution (sees temporal resolution) architecture.
