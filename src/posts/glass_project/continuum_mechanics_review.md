---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Continuum mechanics
layout: layouts/post.njk
---



asdf

# "Tensor analysis"


* A 2-tensor `$$\mathbf{Q} $$` can be written as `$$ \mathbf{Q} = \frac{\mathbf{Q} + \mathbf{Q}^\top}{2} + \frac{\mathbf{Q} - \mathbf{Q}^\top}{2} $$`,
where the first operator is symmetric and the second operator is skew-symmetric.
* We also have `$$ \mathbf{Q} = \mathbf{R}\mathbf{S} $$` with `$$\mathbf{R}$$` orthogonal and `$$\mathbf{S} $$` symmetric.


## The dyadic product:
We define `$$ (\boldsymbol{u} \otimes \boldsymbol{v}) \boldsymbol{w} \equiv (\boldsymbol{w} \cdot \boldsymbol{v}) \boldsymbol{u} $$`
to be the dyadic product (specific case of tensor product). 
In a particular basis `$$ \boldsymbol{u} \otimes \boldsymbol{v} = \mathbf{u} \mathbf{v}^\top$$`.

The natural basis of the space of tensors can be constructed thusly in terms of `$$ \boldsymbol{e}_i \otimes \boldsymbol{e}_j$$`,
for a suitably chosen basis. 

We also define the double-product to be `$$\mathbf{A} : \mathbf{B} \equiv \sum_{i,j=1}^3 A_{ij}B_{ij}$$`.
For higher order tensors this is equivalent to einstein summation notation implicitly specifying summation over the last
index. 

# Kinematics
We assume we have a map `$$\phi : \mathbb{R}^3 \times \mathbb{R}^+ \to \mathbb{R}^3$$` which maps `$$ \boldsymbol{X} \stackrel{\phi(\cdot, t)}{\to} \boldsymbol{x}$$`

The lagrangian ("material") description of density and the eulerian ("spatial") description can therefore be unified as
`$$ \rho = \rho(\boldsymbol{X}, t) = \rho(\phi(\boldsymbol{X}, t), t)$$`, showing that `$$\phi$$` is identified with
the usual "flow map". 

## The deformation gradient:

Let `$$ [\partial_i] $$` be a coordinate frame for the
reference set `$$ \boldsymbol{X}$$` 
so that a (covariant) vector field `$$ X^i \partial_{X_i} $$` on the source manifold `$$X$$` 
and let `$$ \textrm{d}X_i$$` be the dual basis. 
The pushforward `$$\textrm{d}\phi[\partial_{X_i}] =  \pder{x_i}{X_j} \pder{}{x_i} $$`.

