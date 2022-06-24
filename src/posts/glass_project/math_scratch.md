---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Mathematical quantities
layout: layouts/post.njk
---

## A brief note on indexing and notation
In order to keep track of tensors e.g. in point space and spectral space, I like to do the following:
* The index for tetrahedra will be `$$i$$`
* The index for vertex number will be `$$k$$` 
* The index for spectral coefficients will use variable `$$l$$`
* this allows us to write variables `$$_{IK}\mathbf{U}$$` and `$$_{IL}\mathbf{U}$$` which are two tensors containing, respectively, 
point evaluations of the quantity `$$U$$` on tetrahedron `$$i$$` and vertex `$$k = 0,1,2,3$$`, or basis function coefficients
to reconstruct `$$U$$` on tetrahedron `$$i$$` and basis function `$$l=0,1,2,3 $$`

## Affine transformations:

Suppose we have an arbitrary simplex `$$ \mathcal{S}^t $$` which has vertices `$$\mathbf{k}_{0,1,2,3}$$` whose convex hull is our simplex.
We will denote the standard 3-simplex `$$ \mathcal{S}^s $$` which has vertices `$$\mathbf{e}_{0,x,y,z} $$`.

The more relevant quantities for parameterizing `$$\mathcal{S}^t $$` is `$$$J = \begin{bmatrix}
\mathbf{q_1} & \mathbf{q_2} & \mathbf{q_3}
\end{bmatrix} = \begin{bmatrix}
\mathbf{k}_1 - \mathbf{k}_0 & \mathbf{k}_2 - \mathbf{k}_0 & \mathbf{k}_3 - \mathbf{k}_0\end{bmatrix} $$$`

This allows us to express a point `$$\mathbf{x}^t \in \mathcal{S}^t $$` as `$$$ \mathbf{x}(\mathbf{a}) = J \mathbf{a} + \mathbf{k}_0 $$$`
with `$$\mathbf{a} \geq 0 $$` and `$$ \sum_i \mathbf{a} \leq 1 $$`.

Now note: these stipulations guarantee that `$$ \mathbf{a} \in \mathcal{S}^s $$`, which means that we have constructed an affine bijection
`$$$ \mathbf{x} : \mathcal{S}^s \mapsto \mathcal{S}^t $$$` which justifies that `$$\mathcal{S}^s$$` and `$$\mathcal{S}^t $$` are the source and target simplices,
respectively (we will later have indexed `$$\mathcal{S}_i^t $$` to function with our triangulation). 

Finally, if we have some `$$\mathbf{x}^t \in \mathcal{S}^t, $$` then `$$$\mathbf{a}^s = J^{-1}(\mathbf{x}^t - \mathbf{k_0}) $$$` and
this quantity is defined if and only if `$$\mathbf{S}^t $$` is non-degenerate (i.e. it has non-zero volume). This justifies the importance
of using an Delaunay triangulation to maintain good condition numbers for these change-of-basis matrices.

## Higher order shape functions:
The previous section deals with linear shape functions for which enforcing bijectivity is nearly trivial.
However, one of the goals of this project is to have parameterizable horizontal order. As such we would like to 
have a way of treating, e.g. second or third order shape functions. There are a few ways to do this. I'll lay out what I view as the most promising approach here.

The most important consideration here is that we are attempting to formulate our FSI framework in a lagrangian framework.
The spectral discretization that we're trying to formulate requires the use of a projection operator. In curvilinear coordinates,
projection of discontinuous quantities onto a continuous subspace necessitates the use of a globally continuous basis function 
(that is, `$$\mathcal{C}^0$$` at element boundaries).

If we were to update our positions `x` with a `$$v \in \mathcal{V}^0$$` (that is, discontinuous), this causes severe problems. 
What we can do is to ensure that projection happens before position update. However, this loses us the discrete stokes theorem
due to the fact that the coordinate map may have discontinuous jacobian at element boundaries. 
I think this is fine for the moment.

Accordingly we can define `$$ \mathbf{x} : \mathcal{S}^s \to \mathcal{S}^t $$` according to 
`$$$ x_i(\mathbf{a}) = \sum_l P_l(\mathbf{a}) $$$`

We can clearly find the jacobian of this transformation `$$ J_{i, j} = \frac{\partial x_i}{\partial a_j}$$`
which allows us to calculate integrals. Inverting this coordinate transformation will only need to be computed if we include a remapping step
and can be done later. However, we can use the fact that `$$\det(J^{-1}) = \det(J)^{-1} $$`





## The spectral basis:

In the first draft of this work we will work with linear basis functions for simplicity.
However, in order to gain automatic mass lumping for numerical convenience later, we will work directly with 
a set of linear basis functions which are orthogonal w.r.t. integration on the standard simplex.
Note that because the change of variables to and from the canonical element `$$\mathcal{S}^s $$` is affine, the change-of-variables
formula for 3d integration means that for basis functions `$$P_{0, 1, 2, 3} $$`
<table class="eqn">
  <tr><td>$$\iiint_{\mathcal{S}^s} P_i(\mathbf{a})P_j(\mathbf{a})\, \mathrm{d} V $$</td><td> $$= \iiint_{\mathcal{S}^t} P_i(\mathbf{a}(\mathbf{x}))P_j(\mathbf{a}(\mathbf{x})) \det(\mathrm{D}\mathbf{a} )\, \mathrm{d} V$$</td>
  </tr>
  <tr>
    <td></td><td> $$= \iiint_{\mathcal{S}^t} P_i(\mathbf{a}(\mathbf{x}))P_j(\mathbf{a}(\mathbf{x})) \det(J^{-1}(\mathbf{x}))\, \mathrm{d} V$$</td>
  </tr>
</table>
and so orthogonality is preserved under this affine transformation. 

It's actually surprisingly hard to find a systematic derivation of orthogonal polynomials on the standard tetrahedron (note, don't
search for "on the simplex" because this gets you references that are more technical than you need). However, the first-order functions
are given in [this paper](https://ieeexplore.ieee.org/document/8146193), along with an algorithmic method for deriving higher-order bases.

### The basis functions:
<table class="eqn">
  <tr><td>$$P_{000}(\mathbf{a}) $$</td><td> $$= 1 $$</td>
  </tr>
  <tr><td>$$P_{100}(\mathbf{a}) $$</td><td> $$= \begin{bmatrix} 2 & 1 & 1\end{bmatrix}\mathbf{a}- 1$$</td>
  </tr>
  <tr><td>$$P_{010}(\mathbf{a}) $$</td><td> $$= \begin{bmatrix} 0 & 3 & 1\end{bmatrix}\mathbf{a}- 1$$</td>
  </tr>
  <tr><td>$$P_{001}(\mathbf{a}) $$</td><td> $$= \begin{bmatrix} 0 & 0 & 4\end{bmatrix}\mathbf{a}- 1$$</td>
  </tr>
</table>
Note that in this project I will be making strong distinction between a vector (i.e. an element of a vector space) and a functional (i.e. an element of its dual).
This means that `$$\mathbf{a} $$` is a vector (in engineering terminology, a "column vector") and `$$ \mathbf{a}^\top $$` is a linear functional
which lies in the dual vector space. This terminology and notation is a compromise between the convenience and practicality of engineering
and the underlying intuition which comes from the language of PDEs.


## Interpolation

Suppose that we have a quantity `$$U(\mathbf{x})$$` and we have point evaluations at `$$\mathbf{k}_{\ldots} $$`, respectively `$$_K\mathbf{U} $$` i.e. we are working on a finite 
element with values stored at the vertices (often referred to as "nodes" in the FEM literature for some reason). We want to find a vector `$$_L\mathbf{U}$$`
such that`$$~_K\mathbf{U} = \sum_{l} ~_L\mathbf{U}_l P_{l}(\mathbf{k}_k) $$` for `$$k = 0,1,2,3$$`.
In full dimensionality, these can be calculated by
`$$$~_L\mathbf{U}_l = \iiint_{S^s} U(\mathbf{x}(\mathbf{a}))P_l(\mathbf{a}) \det(J^{-1}) \,\mathrm{d} V  $$$`

<!-- Thankfully, for first order simplical elements decent quadrature points for `$$\mathcal{S}^s$$` are merely its vertices. In order to 
solve for the numerical integration weights, we solve a system of linear equations. The matrix can be best understood as
`$$\mathbf{P}_{kl} = P_l(\mathbf{a}(\mathbf{k}_k) $$` such that if we have `$$~_{K}\mathbf{w}_k $$` integration weights, then
`$$\mathbf{P}_{kl} \mathbf{w}^k = ~_L\mathbf{1}.$$` Because I'm a moron let's write this system out in gory detail:

`$$$\begin{bmatrix}
1 & 1 & 1 & 1 \\
-1 & 1 & 0 & 0 \\
-1 & -1 & 4 & 0 \\
-1 & -1 & -1 & 9
\end{bmatrix}
\begin{bmatrix}
w_0\\
w_1\\
w_2\\
w_3
\end{bmatrix}
= \begin{bmatrix}
1\\
0\\
0\\
0
\end{bmatrix}
$$$`

Which I calculated with the following code
<details>
<summary>eval.py</summary>

```
import numpy as np
  
def evl(x, y, z):
  p1 = np.ones_like(x)
  p2 = 2 * x + 1 * y + 1 * z - 1
  p3 = 0 * x + 3 * y + 1 * z - 1
  p4 = 0 * x + 0 * y + 4 * z - 1
  return (p1, p2, p3, p4)
x = np.array([0, 1, 0, 0])
y = np.array([0, 0, 1, 0])
z = np.array([0, 0, 0, 1])
print(evl(x, y, z))
  
  
A = np.array([[1,1,1,1],
              [-1,1,0,0,],
              [-1,-1,4,0,],
              [-1,-1,-1,9]])
b = np.array([1,0,0,0])

w = np.linalg.solve(A,b)
print(w)
```

</details> -->

## Quadrature by copy-paste

Since we're calculating products of linear functions let's use second-order gaussian quadrature,
which we'll take from [this useful site](https://www.cfd-online.com/Wiki/Code:_Quadrature_on_Tetrahedra)

<details>
<summary>gauss_quadrature.py</summary>

```
xa=np.array([0.2500000000000000, 0.0000000000000000, 0.3333333333333333, 0.3333333333333333, 0.3333333333333333, 
     0.7272727272727273, 0.0909090909090909, 0.0909090909090909, 0.0909090909090909, 0.4334498464263357, 
     0.0665501535736643, 0.0665501535736643, 0.0665501535736643, 0.4334498464263357, 0.4334498464263357])
ya=np.array([0.2500000000000000, 0.3333333333333333, 0.3333333333333333, 0.3333333333333333, 0.0000000000000000, 
     0.0909090909090909, 0.0909090909090909, 0.0909090909090909, 0.7272727272727273, 0.0665501535736643, 
     0.4334498464263357, 0.0665501535736643, 0.4334498464263357, 0.0665501535736643, 0.4334498464263357])
za=np.array([0.2500000000000000, 0.3333333333333333, 0.3333333333333333, 0.0000000000000000, 0.3333333333333333, 
     0.0909090909090909, 0.0909090909090909, 0.7272727272727273, 0.0909090909090909, 0.0665501535736643,
     0.0665501535736643, 0.4334498464263357, 0.4334498464263357, 0.4334498464263357, 0.0665501535736643])
wt=np.array([0.1817020685825351, 0.0361607142857143, 0.0361607142857143, 0.0361607142857143, 0.0361607142857143, 
     0.0698714945161738, 0.0698714945161738, 0.0698714945161738, 0.0698714945161738, 0.0656948493683187, 
     0.0656948493683187, 0.0656948493683187, 0.0656948493683187, 0.0656948493683187, 0.0656948493683187])/6
 
```
  
  
  
</details>

<!-- Write these coordinates in the form of `$$ ~_{KR}\mathbf{G}_k$$`, (using convex combinations) where `$$ ~_{DR}\mathbf{G} =  ~_{KR}\mathbf{G}_k ~_{KD} \mathbf{k}^k $$` -->
We assume that we can work with a tensor `$$ ~_{R}\mathbf{U} $$` which is evaluated at the above points. 
If necessary we can interpolate `$$~_{L}\mathbf{U}$$` to these points using `$$~_{R}\mathbf{U} = ~_{L}\mathbf{U}_l ~_{LR}\mathbf{P}^l$$`
`$$$~_L\mathbf{U} =  ~_{R}\mathbf{U}_r  (~_{LR}\mathbf{P} ~_R\mathbf{w}~_R\mathbf{Q})^r  $$$`




## Shape functions and matrices:

### The mass matrix

From the paper this has the form
`$$$ \mathbf{M} = \rho \iiint_{\mathcal{S}^t} \begin{bmatrix} P_0 & P_1 & P_2 & P_3 \end{bmatrix}^\top(\mathbf{a})\begin{bmatrix} P_0 & P_1 & P_2 & P_3 \end{bmatrix}(\mathbf{a}) \det(J^{-1}) \, \mathrm{d} V$$$`

And we can thus find that 

`$$$ ~_{LM}\mathbf{M} = \rho (~_{LR}\mathbf{P}_l ~_{MR}\mathbf{P}_m)_r (~_R\mathbf{w} ~_R\mathbf{J})^r $$$`

However, we note that for `$$l\neq m$$` the orthogonality of the polynomials show that we can treat `$$~_{LM}\mathbf{M} = \mathrm{diag} ~_{L}\mathbf{M}.$$`
This gives an automatically lumped finite element method. Neat.

### The laplacian

The paper gives
`$$$ \mathbf{L} = \iiint_{\mathcal{S}^t} \begin{bmatrix} \nabla P_0 & \nabla P_1 & \nabla P_2 & \nabla P_3 \end{bmatrix}^\top(\mathbf{a})\begin{bmatrix} \nabla P_0 & \nabla P_1 & \nabla P_2 & \nabla P_3 \end{bmatrix}(\mathbf{a}) \det(J^{-1}) \, \mathrm{d} V$$$`

and in tensor form this gives

`$$$ ~_{LM} L = (~_{DLR}\mathbf{P}_{ld}' ~_{DMR}\mathbf{P}_{m}'^d)_r (~_R\mathbf{w} ~_R\mathbf{J})^r $$$`


### The gradient

`$$$ \mathbf{G} = \iiint_{\mathcal{S}^s} \begin{bmatrix} \nabla P_0 & \nabla P_1 & \nabla P_2 & \nabla P_3 \end{bmatrix} (\mathbf{a})\begin{bmatrix}  P_0 &  P_1 & P_2 &  P_3 \end{bmatrix}^\top(\mathbf{a}) \det(J^{-1}) \, \mathrm{d} V$$$`

which in tensor form gives

`$$$ ~_{DLM}\mathbf{G} = (~_{DLR}\mathbf{P}'_{ld} ~_{MR}\mathbf{P}_m)_r (~_{R}\mathbf{w} ~_R\mathbf{Q})^r $$$`

### The forcing term

This has the form 
`$$$ \mathbf{F} = \iiint_{\mathcal{S}^t} \rho \begin{bmatrix} P_0 & P_1 & P_2 & P_3 \end{bmatrix} \mathbf{g} \, \mathrm{d} V  + \iint_{\partial_k \mathcal{S}^t} p_a \mathbf{n} \, \mathrm{d} A$$$`

This is ostensibly due to the paper, but this seems kind of wrong.

`$$$ ~_{DL}\mathbf{F} = (~_{DR}\mathbf{g}_r ~_{LR}\mathbf{P}_r)_r (~_{R}\mathbf{w} ~_R\mathbf{Q})^r+ (((~_{T}\mathbf{p}_t ~_{D}\mathbf{n}_d)_t (~_{T}\mathbf{w'} ~_T\mathbf{Q})^t)_d~_{LR}\mathbf{P}_r)(~_R\mathbf{w}~_R\mathbf{Q})^r) $$$`



## Towards linearization + prep for newton's method

The monolithic equation takes the form
<table class="eqn">
  <tr><td> $$\mathbf{M} \frac{\mathbf{\overline{v}_{n+1} - \overline{v}_n}}{\Delta t} + \mu \mathbf{L}\overline{\mathbf{v}}_{n+1} + \mathbf{G}\overline{\mathbf{p}}_{n+1}$$ </td><td> $$ = \mathbf{F} $$ </td>
 </tr>
  <tr><td>$$\mathbf{D} \overline{\mathbf{v}}_{n+1} + \mathbf{S} \overline{\mathbf{p}}_{n+1}$$</td><td>$$ = 0 $$</td>
  </tr>
</table>


And the next step is to introduce an auxiliary velocity guess `$$\tilde{\mathbf{v}}$$` and a pressure guess 
`$$ \mathbf{p}_{n+1}^g $$` to decouple the linear pressure poisson's equation from the nonlinear momentum equation.

These will be treated separately. The equations read
<table class="eqn">
  <tr>
    <td> $$\mathbf{M} \frac{\tilde{\mathbf{v}} - \overline{\mathbf{v}}_n}{\Delta t} + \mu \mathbf{L} \overline{\mathbf{v}}_{n+1} + \mathbf{G} \overline{\mathbf{p}}_{n+1}^g $$ </td> <td> $$ = \mathbf{F} $$</td>
  </tr>
  <tr>
    <td>$$\mathbf{M} \frac{\overline{\mathbf{v}}_{n+1} - \tilde{\mathbf{v}}}{\Delta t}  + \mathbf{G} \left(\overline{\mathbf{p}}_{n+1} - \overline{\mathbf{p}}_{n+1}^g \right)$$</td> <td> $$ = 0 $$</td>
  </tr>
  <tr>
    <td>$$ \mathbf{D}\overline{\mathbf{v}}_{n+1} + \mathbf{S} \overline{\mathbf{p}}_{n+1}  (\textrm{EOS momentum})$$</td>
  </tr>
</table>

We make some clever rearrangements to get
`$$$\mathbf{D}\tilde{\mathbf{v}} = \Delta t \mathbf{D}\mathbf{M}^{-1} \mathbf{G}\left(\overline{\mathbf{p}}_{n+1} - \overline{\mathbf{p}}_{n+1}^g \right) + \mathbf{S}\overline{\mathbf{p}}_{n+1} (\textrm{pressure poisson})$$$`

Which we substitute for the middle equation. They make the "approximation" that `$$ \mathbf{D} \mathbf{M}^{-1} \mathbf{G} \approx \mathbf{L} $$`
Given that our method is carefully designed to be lumped, I assume that I can treat this more rigorously.

The idea for solution is essentially as follows:
Come up with an appproximation for the guess. Analytically this can
be given as `$$$ p_{n+1}^g = p_n + \kappa \int_{t_n}^{t_{n+1}} \nabla \cdot \mathbf{v} \, \mathrm{d} t (\textrm{pressure guess})$$$` 
However, the discretized approximation is written incorrectly in the paper. We posit that
`$$$\overline{\mathbf{p}}_{n+1} = \overline{\mathbf{p}}_n + \kappa \Delta t \mathbf{M}^{-1}_p \mathbf{D}\tilde{\mathbf{v}} $$$`
is a well-posed guess. We hypothesize here that the use of `$$\mathbf{M}_p$$` is to accomodate potentially different 
order methods for pressure and velocity.



Note: the residual is written incorrectly. Thus the correct residual should read:
<table class="eqn">
  <tr><td>$$ \mathbf{r}_m  $$</td> <td> $$ = \mathbf{F} - \left(\mathbf{M} \frac{\tilde{\mathbf{v}} - \overline{\mathbf{v}}_n}{\Delta t} + \mu \mathbf{L} \tilde{\mathbf{v}} + G\overline{\mathbf{p}}_{n+1}^g(\tilde{\mathbf{v}})\right)$$</td>
  </tr>
  <tr>
      <td></td><td>$$ = \mathbf{F} - \left(\mathbf{M} \frac{\tilde{\mathbf{v}} - \overline{\mathbf{v}}_n}{\Delta t} + \mu \mathbf{L} \tilde{\mathbf{v}} + G\left(\overline{\mathbf{p}}_n + \kappa \Delta t \mathbf{M}^{-1}_p \mathbf{D}\tilde{\mathbf{v}}\right)\right) $$</td>
  </tr>
</table>


Actually solving this is a pretty straightforward application of newton's method to solving `$$\mathbf{r}_m(\tilde{\mathbf{v}}) = 0 $$` namely
`$$$ -\mathbf{J}_{\mathbf{r}_m}\left(\tilde{\mathbf{v}}^{i+1} - \tilde{\mathbf{v}}^{i}\right) \equiv -\mathbf{J}_{\mathbf{r}_m}(\delta \tilde{\mathbf{v}}) = \mathbf{r}_m(\tilde{\mathbf{v}}^i; \overline{\mathbf{v}}_n, \overline{\mathbf{p}}_n) (\textrm{newton})$$$`

We use the notation `$$\mathbf{J} = \frac{\delta \mathbf{r}_m}{\delta \tilde{\mathbf{v}}} $$`

For the sake of convenience we assume that the mass and differential assemblies depend merely on the present 
position of the mesh `$$\tilde{\mathbf{x}}^i$$`. This makes our life rather easy. This means our picard linearization takes the form (which agrees with [this paper](https://www.sciencedirect.com/science/article/pii/S0213131515000589))

`$$$\mathbf{J}_{\mathbf{r}_m} = (\Delta t)^{-1}\mathbf{M} + \mu \mathbf{L} + \kappa \Delta t \mathbf{G}\mathbf{M}_p^{-1} \mathbf{D} $$$`


Therefore we are ready to actually calculate what we need to calculate:

### Fractional momentum
Do while not converged:
1. Calculate the nodal pressure guess `$$\overline{\mathbf{p}}_{n+1}$$` using the `$$\textrm{pressure guess} $$` equation.
2. Use the `$$\textrm{newton} $$` equation to solve for `$$\delta \tilde{\mathbf{v}}$$`
3. Update `$$\tilde{\mathbf{v}}^{i+1} = \tilde{\mathbf{v}}^i + \delta \tilde{\mathbf{v}}$$`
4. Update `$$ \tilde{\mathbf{x}}^{i+1} = \overline{\mathbf{x}}_n + \tilde{\mathbf{v}}^{i+1} $$` (this might require an integration depending on velocity order)
5. Update shape operators with new shape matrix

###  Poisson
Solve the linear `$$ \textrm{pressure poisson} $$` equation using the pressure guess as boundary conditions at the free surface or at structural interfaces.

### End-of-step momentum equation

Solve the linear `$$ \textrm{EOS momentum} $$` equation.



###  Temperature:

The viscosity relationship given in the paper takes the form
`$$$\log_{10}(\mu) = A + \frac{B}{T-T_0} $$$`

The continuum governing equation for temperature evolution takes the form
`$$$ \rho c \frac{\mathrm{d}T}{\mathrm{d}t} = k \Delta T + q $$$`

In the paper they give the following discretization:
`$$$\rho c \mathbf{M}  \frac{\mathbf{T}_{n+1} - \mathbf{T}_{n}}{\Delta t}  = k \mathbf{L}\mathbf{T}_{n+1} + \mathbf{Q} $$$`

where `$$\mathbf{Q} = \int_{\Omega} q\mathbf{N} \, \mathrm{d} \Omega  $$`

My inclination is that the most consistent way to treat this is to add it as part of the implicit
velocity update. However, this adds a drastic increase in computational cost and potentially
a tremendous stability problem if temperature differences are large. 
A good first approximation is to add it as an implicit secondary step after all fluid cost is done.
However! In the case that we go to an imex method that handles variable viscosity elegantly, 
this should become part of the monolithic solver again. 

## Notes on possible alternate time-stepping methods
Limitations of FSI mean that explicit treatment of convective terms (e.g. as is done in IMEX methods)
might not be possible if we do things in the most naive way. It's likely that we could correct for this
by an additional correction step at the expense of reduced fidelity at said boundaries (and potentially
mass conservation problems). The most obvious constraints at fluid-structure boundaries 
are no-flux constraints.

We also have an appealing little hack that would be a _delicious_ test of our numerics.
Namely, we treat our problem as though we are lampworkers who leave their 
work piece attached to a piece of cold glass. This tests the capability of said method
to handle extremely heterogeneous viscosities. I'm inclined to go with this if I go with a more exotic
IMEX method.

That said we could try for IMEX BDF2 from [this paper](https://arxiv.org/pdf/2112.04167.pdf)

## Multi-element assembly

If we have a discontinuous scalar field in coefficient form `$$_{IL}\mathbf{U}$$`, 
the process of projecting it into the `$$\mathcal{V}^1$$` subspace first involves
an interpolation step, namely `$$ _{IK}\mathbf{U} = (_{IL}\mathbf{U}_l\ _{KL}\mathbf{P}^l)$$`


The operations that allow us to derive the actual assembly are as follows:
1. isolate shared points.
2. Multiply by determinant of mass matrix.
3. Sum over redundant elements. 
4. Broadcast `$$\mathcal{C}^0 $$` boundary values back to elements.
5. Project onto spectral coefficients
6. If necessary, interpolate back to point values.

Note: vector quantities need to be handled differently.

### in tensor form:
We're indexing in-element GLL points using the index `$$ R $$` but for the purposes of this section
we create an index `$$ Y $$` which contains function values for duplicate GLL nodes that appear on an element's boundary.
One can immediately assume that the magnitude of `$$ Y $$` will be  `$$ \mathcal{O}(R) $$`. 
We create a special tensor `$$ ~_{Y}\mathbf{m} = ~_{Y}\mathbf{w} ~_{Y}\mathbf{Q} $$` that contains necessary integration 
information communicated from other elements (and particularly other far-away memory)

I'll use `$$~_{YR}\mathbf{\Gamma}$$` to represent the Gather matrix which has entry 
`$$\mathbf{\Gamma}_{yr} = 1$$` if and only if `$$y$$` and `$$r$$` refer to the same geometric GLL node,
and `$$\mathbf{\Gamma}_{yr} = 0$$` otherwise. 

Therefore we can represent a scalar projection according to
`$$$~_{L}\overline{\mathbf{f}} = (~_{LR}\mathbf{P} ~_R\mathbf{w}~_R\mathbf{Q})_r (~_{YR}\Gamma_y(~_{Y}\mathbf{f} ~_{Y}\mathbf{m})^y)^r $$$`



## Differential operators in curvilinear coordinates

Define the coordinate functions `$$ \mathbf{g}_i = \frac{\partial \mathbf{x}}{\partial a_i} $$`

We can define the determinant of the jacobian as `$$ \det(J) = \left|\mathbf{g}_1 \times \mathbf{g}_2 \cdot \mathbf{g}_3\right| $$`

Note that if we're a little mathematically sloppy, we can write a vector `$$\mathbf{v}$$` 
