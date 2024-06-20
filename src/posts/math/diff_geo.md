---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Differential geometry
  parent: math
layout: layouts/post.njk
---

We follow the hyperspeed introduction to differential geometry (not topology!) given in [this monograph](https://bookstore.ams.org/mmono-191)

Suppose we have a manifold `$$S$$` (without boundary), and let `$$\phi : S \to \mathbb{R}^n$$` be 
a coordinate chart `$$ \phi(p) = [\xi^1(p), \ldots, \xi^n(p)]$$`. 
If we have another suitably smooth coordinate chart `$$ \psi = [\rho^i]$$`,
we can define the coordinate transform `$$ \phi \circ \psi^{-1} : [\rho^i] \mapsto [\xi^i]$$`.
Use the usual tricks to define a smooth manifold, smooth functions by composing coordinates to get
maps between `$$\mathbb{R}^n \mapsto \mathbb{R}^n$$` and calculating elementary partial derivatives.

Note that for `$$C^\infty$$` coordinates, we have 
`$$$ \pder{\xi^i}{\rho^j} \pder{\rho^j}{\xi^k} = \delta_k^i $$$` 
with `$$\delta_k^i$$` the kronecker delta symbol.
This is just a reprasing of the multivariate chain rule applied to the 
composition `$$ (\phi \circ \psi^{-1}) \circ (\phi \circ \psi^{-1})^{-1} = \textrm{id}.$$`
Using the same linear map interpretation of the jacobian `$$ [\pder{\xi^i}{\rho^j}]$$`,
we get `$$ \pder{f}{\rho^j} = \pder{\xi_i}{\rho_j} \pder{f}{\xi_i}$$`


## Tangent space:
Consider `$$\gamma : I \to S$$`, with `$$I\subset \mathbb{R}$$` an interval. Let `$$ f \in C^\infty(S)$$`.
If we let `$$\gamma^i = \xi^i(\gamma(t))$$`, then `$$$\der{}{t} f(\gamma(t))  = \left( \pder{f}{\xi^i} \right)_{\gamma(t)} \dot{\gamma}^i(t)$$$`
from vector calculus.

This motivates defining the linear operators 
`$$ \left( \pder{}{\xi^i} \right)_p : f \in C^\infty(S) \mapsto \left(\pder{f}{\xi^i} \right)_p,$$`
which satisfy
`$$$ \left(\pder{\xi^i}{\rho^j} \right)_p  \left(\pder{}{\xi^i} \right)_p = \left(\pder{}{\rho^j} \right)_p,$$$`
where the first term is a real scalar and then second two terms are linear operators. This gives
`$$$
\begin{align*}
\der{}{t} f(\gamma(t))  &= \dot{\gamma}^i(t) \left(\pder{}{\xi^i}\right)_{\gamma(t)} [f] = \dot{\gamma}^i(t) \left[\left(\pder{\rho^j}{\xi^i}\right)_{\gamma(t)} \left(\pder{}{\rho^j}\right)_{\gamma(t)}\right] [f]
\end{align*}
$$$`
motivating that we can either construct the tangent space from the typical cartesian product operators of 1d spaces
`$$ \left( \pder{}{\xi^i} \right)_p $$`,
or define it in terms of equivalence classes of `$$\dot{\gamma}^i$$` that calculate equivalent directional derivatives
in the vector calculus sense. The chain rule specified above constructs a mapping between tangent vectors
specified in one coordinates in terms of the reference coordinate.

For notational convenience, we call `$$\left(\pder{}{\xi_i}\right)_p$$` the natural basis for 
a coordinate `$$[\xi^i]$$`, and that the tangent space is `$$T_p(S) \equiv \left\{c^i \left(\pder{}{\xi^i}\right)_{p} \mid c_i \in \mathbb{R}\right\} $$`

If we have `$$\lambda : S \to Q$$`, and if `$$[\xi^i]$$` and `$$[\rho^j]$$` are coordinates for `$$S, Q$$` respectively, then
`$$$
(\textrm{d} \lambda)_p \left[\left(\pder{}{\xi^i}\right)_{p} \right] = \left(\pder{(\rho^j \circ \lambda)}{\xi^i}\right)_p \left(\pder{}{\rho^j}\right)_{\lambda(p)}
$$$`

## Vector fields:
A map `$$ X : N \to T(S)$$` is a vector field. The choice of natural coordinates `$$[\partial_i] \equiv [\pder{}{\xi^i}] $$` (when this is unambigious)
allows us to identify `$$\{X^1, X^2, X^3\}$$` with the coordinate functions such that `$$X(p) = X^i(p) (\partial_i)_p.$$`

If we write in another basis `$$X = \tilde{X}^j(\tilde{\partial}_j)_p$$` then by the equations above,
`$$X^i = \tilde{X}^j\pder{\xi^i}{\rho^j}$$` and let `$$ \mathcal{T}$$` be the space of `$$C^\infty$$` vector fields. 

Denote by `$$[T_p]^q_r$$` the multilinear mappings from `$$r$$` direct products of `$$T_p(S)$$` 
to either `$$T_p$$` if `$$q=1$$` or `$$\mathbb{R}$$` if `$$q=0$$`. A tensor field of type `$$(q, r)$$`
is an assignment of an element in `$$[T_p]^q_r$$` to each point of `$$S$$`, e.g. `$$ A : p \in S \mapsto A_p \in [T_p]^q_r$$`.
`$$r$$` is the covariant degree and `$$q$$` is the contravariant degree.
Let 
