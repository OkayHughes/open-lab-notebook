---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Idealized eta coordinates
  parent: DCMIP 2024
layout: layouts/post.njk
---

We're going to follow the strategy outlined in DCMIP 2008.
We use the definition `$$ p(\eta) = A(\eta) p_0 + B(\eta) p_s$$`

1. Establishing a reference temperature profile `$$T(z)$$`.
2. Use this to determine pressure levels `$$p_{\textrm{int}, k} = p(z_{\textrm{int}, k}) $$`
3. Calculate sigma levels assuming isobaric surface pressure, `$$\sigma_{\textrm{int}, k} = \frac{p_{\textrm{int}, k} - p_{\textrm{int}, 1}}{p_{\textrm{int}, N+1} - p_{\textrm{int}, 1}}$$`
4. Define `$$A(\eta) = \eta - B(\eta)`