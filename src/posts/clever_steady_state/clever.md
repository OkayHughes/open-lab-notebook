---
date: 2021-08-31
tags:
  - posts
  - directory
eleventyNavigation:
  key: clever steady state
layout: layouts/post.njk
---

We can formulate the equations of motion as
`$$$ \partial_t \mathbf{u} + \mathbf{F}(u) = \mathbf{f}(u) $$$`

We wish to find a steady state, namely `$$\partial_t u = 0$$`
which gives us the relation `$$ \mathbf{F}(u) - \mathbf{f}(u) = 0$$`

Let `$$ \mathbf{G}(u) = \mathbf{F}(u) - \mathbf{f}(u)$$`

Then we can root find using newton's method, namely 
`$$ \mathbf{u}_{n+1} = \mathbf{u}_n - J_\mathbf{G}(\mathbf{u})^{-1} \mathbf{G}(u) $$`

Here's the difficulty: how do we compute `$$J_{\mathbf{G}} $$`? 
This is done in implicit solvers, but 