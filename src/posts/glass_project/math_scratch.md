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
indices for point space will be indexed by `$$i$$` and indices for spectral space will use variable `$$k$$`,
in which case `$$_iU`

## Affine transformations:

Suppose we have an arbitrary simplex `$$ \mathcal{S}^t $$` which has vertices `$$\mathbf{k}_{0,1,2,3}$$` whose convex hull is our simplex.
We will denote the standard 3-simplex `$$ \mathcal{S}^s $$` which has vertices `$$\mathbf{e}_{0,x,y,z} $$`.

The more relevant quantities for parameterizing `$$\mathcal{S}^t $$` is `$$$Q = \begin{bmatrix}
\mathbf{q_1} & \mathbf{q_2} & \mathbf{q_3}
\end{bmatrix} = \begin{bmatrix}
\mathbf{k}_1 - \mathbf{k}_0 & \mathbf{k}_2 - \mathbf{k}_0 & \mathbf{k}_3 - \mathbf{k}_0\end{bmatrix} $$$`

This allows us to express a point `$$\mathbf{x}^t \in \mathcal{S}^t $$` as `$$$ \mathbf{x}(\mathbf{a}) = Q \mathbf{a} + \mathbf{k}_0 $$$`
with `$$\mathbf{a} \geq 0 $$` and `$$ \sum_i \mathbf{a} \leq 1 $$`.

Now note: these stipulations guarantee that `$$ \mathbf{a} \in \mathcal{S}^s $$`, which means that we have constructed an affine bijection
`$$$ \mathbf{x} : \mathcal{S}^s \mapsto \mathcal{S}^t $$$` which justifies that `$$\mathcal{S}^s$$` and `$$\mathcal{S}^t $$` are the source and target simplices,
respectively (we will later have indexed `$$\mathcal{S}_i^t $$` to function with our triangulation). 

Finally, if we have some `$$\mathbf{x}^t \in \mathcal{S}^t, $$` then `$$$\mathbf{a}^s = Q^{-1}(\mathbf{x}^t - \mathbf{k_0}) $$$` and
this quantity is defined if and only if `$$\mathbf{S}^t $$` is non-degenerate (i.e. it has non-zero volume). This justifies the importance
of using an Delaunay triangulation to maintain good condition numbers for these change-of-basis matrices.

## The spectral basis:

In the first draft of this work we will work with linear basis functions for simplicity.
However, in order to gain automatic mass lumping for numerical convenience later, we will work directly with 
a set of linear basis functions which are orthogonal w.r.t. integration on the standard simplex.
Note that because the change of variables to and from the canonical element `$$\mathcal{S}^s $$` is affine, the change-of-variables
formula for 3d integration means that for basis functions `$$P_{0, 1, 2, 3} $$`
<table class="eqn">
  <tr><td>$$\iiint_{\mathcal{S}^s} P_i(\mathbf{a})P_j(\mathbf{a})\, \mathrm{d} V $$</td><td> $$= \iiint_{\mathcal{S}^t} P_i(\mathbf{x}(\mathbf{a}))P_j(\mathbf{x}(\mathbf{a})) \det(\mathrm{D}\mathbf{x} )\, \mathrm{d} V$$</td>
  </tr>
  <tr>
    <td></td><td> $$= \iiint_{\mathcal{S}^t} P_i(\mathbf{x}(\mathbf{a}))P_j(\mathbf{x}(\mathbf{a})) \det(Q)\, \mathrm{d} V$$</td>
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

Suppose that we have a quantity `$$U(\mathbf{x})$$` and we have point evaluations at `$$\mathbf{k}_{0,1,2,3} $$`, respectively `$$\mathbf{U}_{0,1,2,3} $$` i.e. we are working on a finite 
element with values stored at the vertices (often referred to as "nodes" in the FEM literature for some reason). Here I introduce a trick that I used on
a previous finite element implementation
In full dimensionality, these can be calculated by
`$$$  $$$`