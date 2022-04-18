---
date: 2021-08-31
tags:
  - posts
  - directory
eleventyNavigation:
  key: Little math puzzle
  parent: scratch
layout: layouts/post.njk
---



We want to solve the functional equation 
`$$$ 2^x = g(g(x)) $$$`

In order to do this we limit ourselves to just one branch so that `g^{-1}` is single valued.

`$$$ g^{-1}(2^x) = g(x) $$$`
`$$$ x = \log_2(g(g(x)))  $$$`

## newton rootfinding:

