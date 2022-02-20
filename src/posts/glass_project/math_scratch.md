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
`$$$ \mathbf{x} : \mathcal{S}^s \mapsto \mathcal{S}^t $$$` which justifies that `$$\S$$`