---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Scratch 09 21
  parent: Baroclinic Wave Test Case with Topography
layout: layouts/post.njk
---

## reformulating latitude

Define `$$ d_n = \lambda - \lambda_n \mod 2 \pi  $$`
The analogue of `$$\lambda - \lambda_n $$`
in
`$$$ z_s(\phi, \lambda) = A \sum_{n=1}^2\exp\left[-\left(\left(\frac{\phi - \phi_n}{b} \right)^6  + \left(\frac{\lambda - \lambda_n}{c} \right)^2 \right) \right]  $$$`
and
`$$$
    w(\phi, \lambda, \overline{z}) = -\frac{u}{a\cos(\phi)}\left(2A\left( 1 - \frac{\overline{z}}{z_{\mathrm{top}}} \right) \sum_{i=1}^2 \left(\frac{\lambda - \lambda_i}{\bar{c}^2} \right) \exp\left[-\left(\left(\frac{\phi - \phi_n}{\bar{b}} \right)^6  + \left(\frac{\lambda - \lambda_n}{\bar{c}} \right)^2 \right) \right] \right)
$$$`
is `$$ \min(d_n, 2\pi - d_n)$$`

We make the following definition 
