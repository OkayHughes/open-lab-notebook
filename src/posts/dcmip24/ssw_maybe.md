---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Odd function base state
  parent: DCMIP 2024
layout: layouts/post.njk
---

The idea is to look and see if the Staniforth & White generalized thermal wind solutions
can be generalized further if we place less of a premium on closed-form solutions.
Can we derive an interesting stratosphere using this method?

The compatibility condition is, letting `$$U \equiv 2\Omega u + \frac{u^2}{r\cos\phi} $$` and `$$ T(r, \phi) = \left(\frac{a}{r} \right)^3 \left[ \tau_1(r) - \tau_2(r) \tau_3\left(\frac{r}{a}\cos\phi \right) \right]^{-1}$$`,
`$$$ \left(\sin(\phi) \pder{}{r} + \frac{\cos\phi}{r} \pder{}{\phi}\right)\left(\frac{U}{T}\right) = \frac{g}{a} \pder{}{\phi} \left(\frac{a^3}{r^3 T} \right) = -\frac{g}{a} \tau_2(r) \pder{}{\phi} \left[ \tau_3\left( \frac{r}{a} \cos\phi \right) \right] $$$`

The 2011 paper indicates that one specifies the latitudinal dependenc