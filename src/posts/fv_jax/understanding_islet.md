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

Let `$$\boldsymbol{r}\in [-1, 1]^2$$` be the element-local reference coordinate. `$$\boldsymbol{x} = m_e(\boldsymbol{r})$$`. Let `$$e = E(\boldsymbol{x})$$` be a single-valued integer returning exactly one index of an element containing `$$ \boldsymbol{x}$$`. 
