---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: fv jax
  key: Islet?
layout: layouts/post.njk
---

Islet is an interpolated SL method, and in this document we're only concerning outselves with the CG variant.

Let `$$\boldsymbol{r}\in [-1, 1]^2$$` be the element-local reference coordinate. `$$\boldsymbol{x} = m_e(\boldsymbol{r})$$`. Let `$$e = E(\boldsymbol{x})$$` be a single-valued integer returning exactly one index of an element containing `$$ \boldsymbol{x}$$`. We will retain the manifold generalization because it very well may be artistically interesting.

Define `$$\textrm{normalize}(\boldsymbol{x}) = \frac{\boldsymbol{x}}{\|\boldsymbol{x}\|_2}$$`,
then using the 2d bilinear basis function (corresponding to `$$n_p = 2$$`),
we calculate the coordinate mapping as 
`$$$\boldsymbol{x}(\boldsymbol{r}) = \textrm{normalize}\left(\sum_{j=0}^3 \boldsymbol{x}_{\textrm{corner}_j} \phi_j^{\textrm{bilin}}(\boldsymbol{r}) \right)  $$$`

Assume for the sake of this derivation that we can precisely calculate 
`$$\tilde{\boldsymbol{x}}_i $$`
