---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Main Glass Post
  key: Code outline
layout: layouts/post.njk
---

The locality of the `$$ H $$` matrix's components mean that the primary computational expense
is solving an extremely sparse matrix (each line of the system contains at most 4 non-zero entries on the LHS).

It is clear that formulation of the `$$ H $$` dynamic tangent matrix can be computed node-by-node in an embarassingly
parallel fashion. 
