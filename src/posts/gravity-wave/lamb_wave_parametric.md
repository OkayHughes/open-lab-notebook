---
date: 2021-08-30
tags:
  - posts
  - gravity_wave
eleventyNavigation:
  key: Parametric Lamb Waves 
  parent: The two-mountain gravity wave
layout: layouts/post.njk
---

Define `$$k $$` to be a single wavelength of zonally propagating lamb wave.

Relevant quantities: 
`$$$p' = p_0 \exp\left(- \int_{z=0}^z \frac{g}{R_d\overline{T}}\, \mathrm{d} z\right) \cos(k(x-ct))$$$`

`$$$ c = \sqrt{\gamma R_d \overline{T}}$$$`

`$$$ u'(z) = - \frac{p_0}{(-c)\overline{\rho}} \exp\left(\frac{g}{R_d \overline{T}} z\right) \cos(k(x-ct)) $$$`

`$$$ u'(z) =  \frac{p_0}{c\rho_0} \cos(k(x-ct)) $$$`

From one of Christiane's presentations we get

`$$$\omega = \mathrm{D}_t p = \partial_t p + \mathbf{v} \cdot \nabla p + w \partial_z p $$$`

`$$$\omega = \left(\frac{R_dT}{pc_p}  - \partial_p T\right)^{-1} \left(\partial_t T + u \partial_x T + v \partial_y T \right) $$$`



Allow variation in horizontal structure of temperature but not vertical. Assume that density is constant in horizontal, vary in vertical.



`$$$(\overline{p}(z) + p'(x, z)) = \overline{\rho}(z) R_d (\overline{T} + T'(x)) $$$`
`$$$ p'(x, z) = \overline{\rho}(z) R_d T'(x)$$$`

And canceling gives `$$$ T'(x) = \frac{p_0}{\rho_0R_d} \cos(k(x-c t)) $$$`

Let's linearize the nonhydrostatic equation in height coordinates to try to figure this out:
`$$$ \mathrm{D}_t w = -\rho^{-1}\partial_z p - g $$$`
`$$$ \overline{\rho}\partial_t w = -\partial_z\overline{p} - \partial_z p' - \overline{\rho} g $$$`
`$$$ \overline{\rho}\partial_t w = - \partial_z p'  $$$`

So I think this gives us full linearized closure of our equations. This can now be implemented.







