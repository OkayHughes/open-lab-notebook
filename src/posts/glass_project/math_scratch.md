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
formula for 3d integration means that 
`$$$\iiint $$$`

