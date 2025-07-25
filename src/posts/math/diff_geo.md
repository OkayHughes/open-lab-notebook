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

We follow the hyperspeed introduction to differential geometry (not topology!) given in [this monograph](https://bookstore.ams.org/mmono-191).
I've found that it's very helpful to include the first 60 pages of [do carmo](https://medusa.teodesian.net/docs/mathematics/Riemannian%20Geometry%20-%20M.%20doCarmo%20(1993)%20WW.pdf).

Note: exterior algebra makes my head hurt, so I've ommitted any treatment of it here.
If this makes certain statements slightly wrong, I'm sorry. 

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

To get cotangent space we start by defining the differential of a smooth function
`$$\mathrm{d}f \in T_p^*M $$` so that `$$ \mathrm{d}f\left(\partial^i \right) = \frac{\partial f}{\partial \xi^i}$$` We start by finding the dual basis
`$$\textrm{d} \xi_i\left(\frac{\partial}{\partial \xi^i} \right) = \delta^i_j$$` 
which allows us to find `$$ \textrm{d}f = \frac{\partial f}{\partial \xi^i} \mathrm{d} \xi_i.$$` This definition aligns with
`$$ \nabla_X f = \mathrm{d}f(X^i \partial_i) = X^i\frac{\partial f}{\partial \xi^i}$$`.
As a result, suppose we have a covector (covariant vector for physicists) `$$ \omega = \omega^i \textrm{d}\xi_i = \tilde{\omega}^j \textrm{d}\rho_j$$`,
then `$$\textrm{d}\rho_j = \frac{\partial \rho_j}{\partial \xi^i} \textrm{d} \xi_i $$` and so `$$ \omega^i = \tilde{\omega}^j \frac{\partial \rho^j}{ \partial \xi^i}  $$`.
This motivates the notion that "covariant" vectors transform according to the inverse of the Jacobian (`$$\frac{\partial \rho}{\partial \xi} $$`)
and contravariant vectors transform according to the jacobian `$$  \frac{\partial \xi}{\partial \rho} $$`:
`$$$
\begin{align*}
  \textrm{contravariant: }& X = X^i \left(\frac{\partial}{\partial \xi^i} \right) = \tilde{X}^j \left(\frac{\partial}{\partial \rho^j} \right)  \in T_pM \implies X^i = \tilde{X}^j\pder{\xi^i}{\rho^j} \\
  \textrm{covariant: }&  \omega = \omega_i \textrm{d}\xi_i = \tilde{\omega}_j \textrm{d}\rho_j  \in T_p^*M \implies \omega_i = \tilde{\omega}_j \frac{\partial \rho^j}{ \partial \xi^i} 
\end{align*}
$$$`

Denote by `$$[T_p]^q_r$$` the multilinear mappings from `$$r$$` direct products of `$$T_p(S)$$` 
to either `$$T_p$$` if `$$q=1$$` or `$$\mathbb{R}$$` if `$$q=0$$`. A tensor field of type `$$(q, r)$$`
is an assignment of an element in `$$[T_p]^q_r$$` to each point of `$$S$$`, e.g. `$$ A : p \in S \mapsto A_p \in [T_p]^q_r$$`.
`$$r$$` is the covariant degree and `$$q$$` is the contravariant degree (strictly speaking, the covariant degree are covector fields).
Let `$$A$$` be a tensor field of type `$$q, r$$` and let `$$ X_1, \ldots, X_r$$` be vector fields,




## Characterizing the bracket:
Recall the pushforward of a map `$$\phi : M \to M $$`. We can calculate the pushforward of a vector field 
`$$ (\textrm{d}\phi(X))_0 : X_p \in T_pM \mapsto \textrm{d}\phi(X_p) \in T_{\phi(p)}M $$`.

In order to build up to characterizing the bracket operation, recall that we can 
characterize vector fields as `$$X = X^i \pder{}{\xi^i} $$` which 
are, strictly speaking, differential operators acting on smooth functions as `$$ X(f) = X^i \pder{f}{\xi^i} $$`.
Indeed, on a purely formal level this leads us to consider `$$ X(Y(f))$$` or `$$ Y(X(f))$$`. 
Writing in coordinates we get `$$ X = X^i \partial_i, Y=Y^j\partial_j $$` and then see
`$$$ 
\begin{align*}
  X(Y(f)) &= X\left( Y^j \pder{f}{\xi^j}  \right) = X^i Y^j \frac{\partial^2 f}{\partial \xi^i\partial \xi^j} + X^i \pder{Y^j}{\xi^i} \pder{f}{\xi^j}  \\
  Y(X(f)) &= Y\left( X^i \pder{f}{\xi^i}  \right) = X^i Y^j \frac{\partial^2 f}{\partial \xi^i\partial \xi^j} + Y^j \pder{X^i}{\xi^j} \pder{f}{\xi^i} \\
\end{align*}
$$$`
There are common terms that cancel, motivating the definition 
`$$$
\begin{align*}
   (XY-YX)(f) &= X^i \pder{Y^j}{\xi^i} \pder{f}{\xi^j} - Y^j \pder{X^i}{\xi^j} \pder{f}{\xi^i} \\
   &= \left[X^i \pder{Y^j}{\xi^i} \pder{}{\xi^j} - Y^j \pder{X^i}{\xi^j} \pder{}{\xi^j }\right]f
\end{align*}
$$$`
which is clearly a unique vector field, which we call `$$[X,Y]$$`. 
It's easy to see that the bracket is anticommutative and linear in smooth functions, but also satisfies two additional properties
`$$$
\begin{align*}
  &[[X, Y], Z] + [[Y,Z], X] + [[Z, X], Y] = 0\\
  &[fX, gY] = fg[X, Y] + fX(g)Y - gY(f)X.
\end{align*}
$$$`
This is one natural way to derive a second vector field from two existing vector fields, but
it is not immediately clear what it does. Using elementary ODE theory, one can
derive a flow map `$$\phi_X(t, p)$$` such that `$$ [\partial_t \phi_X](t, p) = X_q, \phi(0, q) = q$$` .
We find that if `$$ X, Y$$` are smooth vector fields, `$$\phi_{t} : p \in M \mapsto \phi(t, \cdot)$$`
`$$$
\begin{align*}
  [X, Y](p) &= \lim_{\Delta t \to 0} \frac{1}{\Delta t}\left[[\textrm{d} \phi_0] Y - [\textrm{d} \phi_{\Delta t}] Y \right](\phi_{\Delta t}(p))\\
  &= \lim_{\Delta t \to 0} \frac{1}{\Delta t}\left[Y - [\textrm{d} \phi_{\Delta t}] Y \right](\phi_{\Delta t}(p))
\end{align*}
$$$`
where the odd choice of sign comes from the fact that the ersatz derivative is being
calculated by evaluating `$$Y, [\textrm{d} \phi_{\Delta t}] Y $$` at `$$ (\phi_{\Delta t}(p)) $$`,
where the apparent type error (`$$ T_pM \neq T_{\phi_{\Delta t}(p)}M$$`) disappears noting
that the convergence is really a statement on vector fields instead of evaluations at a particular point.
The proof comes down to evaluation of vector fields on smooth functions, making this precise. 
Therefore, the bracket measures the rate of change of `$$Y$$` along the trajectories of `$$X$$`.



## The metric:
A metric is a (0, 2) tensor field that is symmetric and positive definite. 
We characterize the smoothness by either `$$ g_{ij} = g(\partial_i \otimes \partial_j) = g(\partial_j \otimes \partial_j) $$`
being a smooth function, or `$$ g(X \otimes Y) $$` being a smooth function (these are clearly equivalent).
I think this motivates the expression `$$ g \simeq g_{ij} (\textrm{d}\xi_i \otimes \textrm{d}\xi_j) $$`
giving the coordinate expression for `$$X = X^i \partial_i, Y = Y^j \partial_j$$` 
`$$$
\begin{align*}
  g(X \otimes Y) = g_{ij}X^k Y^l (\textrm{d}\xi_i \otimes \textrm{d}\xi_j)(\partial_k \otimes \partial_l) = g_{ij}X^kY^l \delta_i^k \delta_j^l = g_{ij}X^iY^j
\end{align*}
$$$`
and as before, the tensor basis `$$ (\textrm{d}\xi_i \otimes \textrm{d}\xi_j) $$` in which `$$g$$` is writen 
transforms covariantly in each tensored covector. 
*This clarifies my enduring confusion: a covariant argument of a tensor 
means that in coordinates, those components of the tensor transform covariantly. 
As a result, covariant arguments to a tensor take contravariant quantities as input.*




If we denote this as `$$g: \Gamma(M) \otimes \Gamma(M) \to \mathbb{R} $$`, then we get
`$$ \omega_X \in \Gamma^*(M) : Y \mapsto g(X \otimes Y)$$`, i.e. the 
usual association between primal and dual vector spaces induced by an inner product. 
A useful exercise at some point would be to formally determine that `$$ \Gamma(M) \otimes \Gamma(M)$$` 
has nice properties and is smooth and stuff.
In any case, we can write `$$g =  g^{ij} (\partial_i \otimes \partial_j ) $$` so that `$$ g_{ij}g^{jk} = \delta_{i}^k$$`.


### Curve length:
Recall from above that the velocity of a curve `$$ \gamma : (a, b) \to M $$` can be derived via smooth `$$f$$` as
`$$$ \der{f(\gamma(t))}{t} = \pder{f}{\xi^i} \der{\xi^i(\gamma(t))}{t} \implies \dot{\gamma}(t) \simeq \dot{\gamma}^i \partial_i $$$`.
Therefore, if `$$ [a', b'] \subset (a,b)$$` then
`$$$
\begin{align*}
 \ell_{a'}^{b'} &\equiv \int_{a'}^{b'} \sqrt{g(\dot{\gamma}(t) \otimes \dot{\gamma}(t))} \intd{t} \\
 &= \int_{a'}^{b'} \sqrt{g([\dot{\gamma}^i \partial_i] \otimes [\dot{\gamma}^j \partial_j])} \intd{t} \\
 &= \int_{a'}^{b'} \sqrt{g_{ij} \dot{\gamma}^i \dot{\gamma}^j} \intd{t} \\
\end{align*}
$$$`

Interesting tidbit: if you're willing to introduce exterior algebra, then you can get volume from this.


## Covariant derivatives and affine connections
Shamelessly stealing from do carmo: suppose we have a surface `$$S \subset \mathbb{R}^3$$`,
a curve `$$ c: (a, b) \to S$$`, and a vector field `$$V : (a, b) \to \mathbb{R}^3$$` that is tangent
to `$$S$$`. The derivative `$$ \der{V}{t}$$` is not necessarily tangent to `$$S$$`, 
but can be projected onto the tangent space. This
is the euclidean analogue of the covariant derivative. 
In particular, the velocity vector `$$\textrm{d}c$$` can be differentiated 
to yield an "acceleration" vector. 
In the euclidean case, one can show that the only curves having zero acceleration are 
geodesics under the induced metric. 
Therefore, in the setting of manifolds, we want to introduce a notion of covariant
derivative that generalizes the notion that `$$\der{V}{t} = 0 $$` 
indicates that `$$ V$$` is parallel to the manifold.

### Affine connection
Here we care only about affine connections in order to build up to the 
unique connection induced by a choice of metric. 

An affine connection is a map `$$ \nabla : \Gamma(M) \times \Gamma(M) \to \Gamma(M) $$` 
denoted by `$$ (X, Y) \mapsto \nabla_X(Y)$$`.

It is specified to have the following properties
1. `$$ \nabla_{fX + gY} Z = f \nabla_X Z + g \nabla_Y Z$$` 
2. `$$ \nabla_X(Y + Z) = \nabla_X(Y) + \nabla_X(Z) $$`
3. `$$ \nabla_X(fY) = f\nabla_X(Y) + X(f)Y$$`

Writing in coordinates we find that for `$$ X = X^i \partial_i $$`, `$$Y = Y^j \partial_j $$`
`$$$
\begin{align*}
  \nabla_{X^i \partial_i} (Y^j \partial_j) &= X^i \nabla_{\partial_i} Y^j \partial_j \\
  &= X^i \left( Y^j \nabla_{\partial_i}(\partial_j) + \pder{Y^j}{\xi^i } \partial_j  \right)
\end{align*}
$$$`
which motivates that `$$ \nabla_{\partial_i} \partial_j \equiv  \Gamma_{ij}^k \partial_k  $$`
so 
`$$$
\begin{align*}
  \nabla_{X^i \partial_i} (Y^j \partial_j) &= X^i Y^j \Gamma_{ij}^k \partial_k + X^i\pder{Y^k}{\xi^i } \partial_k \\ 
  &= (X^i Y^j \Gamma_{ij}^k + X^i\pder{Y^k}{\xi^i })\partial_k
\end{align*}
$$$`


This definition is a little baffling, but this might clarify it.
Let `$$c$$` be a smooth curve and `$$V, W$$` be vector fields on the image of `$$c$$`, and `$$f$$` be a smooth function.
The properties that we want a covariant derivative to satisfy are 
1. `$$ \der{}{t}(V + W) = \der{V}{t} + \der{W}{t}$$`
2. `$$ \der{}{t} (fV) = f\der{V}{t} + \der{f}{t}V $$`
3. If `$$ V(t) = Y(c(t))  $$` for `$$Y$$` a vector field on `$$M$$`, then `$$ \der{V}{t} = \nabla_{\dot{c}} Y$$`

If we suppose such a derivative exists, we can use its properties to determine its form.
If we write `$$ V = V^i \partial_i$$`, then 
`$$$
\begin{align*}
  \frac{DV}{dt} = \der{V^j}{t} \partial_j + V^j \frac{D\partial_j}{dt}
\end{align*}
$$$`
and using (c) we get 
`$$$
\begin{align*}
   \frac{D\partial_j}{dt} &= \nabla_{\dot{c}^i \partial_i} \partial_j \\
   &= \dot{c}^i \nabla_{\partial_i}\partial_j 
\end{align*}
$$$`
which gives
`$$$
\begin{align*}
  \frac{DV}{dt} &= \der{V^j}{t} \partial_j + \dot{c}^i V^j \nabla_{\partial_i}\partial_j \\
  &= \left[ \der{V^k}{t} + \dot{c}^i V^j \Gamma_{ij}^k \right]\partial_k
\end{align*}
$$$`

This gives a useful definition of parallel for a vector field `$$V$$` along `$$c$$` as `$$ \frac{DV}{dt} = 0$$`.

## Riemannian connection:
An affine connection (equivalently: covariant derivative) is compatible with a metric if parallel `$$V, W$$`
along `$$c$$`
satisfy `$$g(V \otimes W) = \textrm{const} $$`. This is equivalent to 
`$$$
\der{}{t} g(V \otimes W) = g(\frac{DV}{dt} \otimes W) + g(V \otimes \frac{DW}{dt}) \textrm{ on } c
$$$`
which makes sense, as the parallel transport of parallel vector fields should preserve the "angle"
between them induced by the metric.
A symmetric affine connection satisfies `$$ \nabla_XY - \nabla_YX = [X,Y]$$`.

Fact: there is a unique symmetric affine connection that is compatible with a Riemannian metric. 
It can be derived from the equivalent characterization of compatibility as `$$ X(g(Y \otimes Z)) = g(\nabla_XY \otimes z) + g(Y \otimes \nabla_XZ)$$`

It has christoffel symbols 
`$$$ \Gamma_{ij}^m = \frac{1}{2} \left[\pder{g_{jk}}{x_i} + \pder{g_{ki}}{x_j} - \pder{g_{ij}}{x_k} \right]g^{km} $$$`



Todo:
  * Covariant derivative
  * Riemannian connection
  * Contravariant tensor -> covariant tensor
  * Divergence of vector field
  * Divergence / covariant derivative of (rank 2) tensor field
  * Induced metric
  * Musical isomorphism
