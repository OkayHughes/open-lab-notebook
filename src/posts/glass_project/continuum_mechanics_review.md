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
Consider two elements of the tangent space of a point `$$\mathrm{d}\boldsymbol{X}_1, \mathrm{d}\boldsymbol{X}_2 $$`
then the deformation gradient is just the differential of `$$\phi$$` written in coordinates,
namely `$$$\boldsymbol{F} = \frac{\partial \phi_i}{\partial X_j} $$$`
which has typing `$$ \boldsymbol{F} : T_{\boldsymbol{X}_j} \boldsymbol{X} \to T_{\phi(\boldsymbol{X}_j, t)} \boldsymbol{x} $$`

We can use the standard argument to write `$$\mathrm{d}\boldsymbol{x} = \phi_*(\mathrm{d}\boldsymbol{X}) = \boldsymbol{F}\mathrm{d}\boldsymbol{X}$$`
`$$\mathrm{d}\boldsymbol{X} = \phi^{-1}_*(\mathrm{d}\boldsymbol{x}) = \boldsymbol{F}^{-1}\mathrm{d}\boldsymbol{x}$$`

This therefore induces a metric 
`$$$ 
\begin{align*}
\mathrm{d}\boldsymbol{x}_i \cdot \mathrm{d}\boldsymbol{x}_j &= \boldsymbol{F}\mathrm{d}\boldsymbol{X}_i \cdot \boldsymbol{F}\mathrm{d}\boldsymbol{X}_j   \\
&= \mathrm{d}\boldsymbol{X}_i \cdot \boldsymbol{F}^\top\boldsymbol{F}\mathrm{d}\boldsymbol{X}_j \\
&\equiv \mathrm{d}\boldsymbol{X}_i \cdot \boldsymbol{C}\mathrm{d}\boldsymbol{X}_j \\
\end{align*}$$$`
which can be shown by index juggling. `$$\boldsymbol{C}$$` 
ends up being called the right Cauchy-Green deformation tensor. 

In the other direction, 
`$$$ 
\begin{align*}
\mathrm{d}\boldsymbol{X}_i \cdot \mathrm{d}\boldsymbol{X}_j &= \mathrm{d}\boldsymbol{x}_i \cdot \boldsymbol{F}^{-\top}\boldsymbol{F}^{-1}\mathrm{d}\boldsymbol{x}_j   
\end{align*}
$$$`
and the left Cauchy-Green tensor is defined as `$$ \boldsymbol{b}^{-1} = \boldsymbol{F}^{-\top}\boldsymbol{F}^{-1} \implies \boldsymbol{b} = \boldsymbol{F} \boldsymbol{F}^{\top}$$`

The difference in inner product induced by the flow map can thus be expressed in material form as
`$$ \frac{1}{2}\left( \mathrm{d}\boldsymbol{x}_i \cdot \mathrm{d}\boldsymbol{x}_j - \mathrm{d}\boldsymbol{X}_i \cdot \mathrm{d}\boldsymbol{X}_j\right) = \mathrm{d}\boldsymbol{X}_i \cdot \boldsymbol{E} \mathrm{d}\boldsymbol{X}_j $$`
with `$$\boldsymbol{E} = \frac{1}{2}(\boldsymbol{C} - \boldsymbol{I}) $$`
and for the spatial form 
`$$ \frac{1}{2}\left( \mathrm{d}\boldsymbol{x}_i \cdot \mathrm{d}\boldsymbol{x}_j - \mathrm{d}\boldsymbol{X}_i \cdot \mathrm{d}\boldsymbol{X}_j\right) = \mathrm{d}\boldsymbol{x}_i \cdot \boldsymbol{e} \mathrm{d}\boldsymbol{x}_j $$`
with `$$\boldsymbol{e} = \frac{1}{2}(\boldsymbol{I} - \boldsymbol{b}^{-1}) $$`


## Pushforward/pullback of tensor

For a tensor `$$ \boldsymbol{B} : T_{X_j}\boldsymbol{X} \times T_{X_j}^*\boldsymbol{X} \to \mathbb{R} $$` , `$$ \boldsymbol{B}() $$`
the pushforward to the target is just `$$\boldsymbol{b}(d\boldsymbol{x}_i, \frac{\partial}{\partial \boldsymbol{x}_j}) \equiv \boldsymbol{B}(\phi_*(d\boldsymbol{x}_i), \phi_*^\top(\frac{\partial}{\partial \boldsymbol{x}_j})$$`



