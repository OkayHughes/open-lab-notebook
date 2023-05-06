---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Code modifications
layout: layouts/post.njk
---

# Finding and modifying the vertical integral
The idea is to do this by modifying the underlying subroutine. Hopefully one exists.
Geopotential used in NH model: called `phinh_i` (only at interfaces). Where is this used?

Brute force: Look through everywhere `nlev` is mentioned.