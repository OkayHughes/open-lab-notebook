---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Scratch for derived omega in hybrid coordinates
  parent: Baroclinic Wave Test Case with Topography
layout: layouts/post.njk
---


Define `$$ p = a_kP_0 + b_k p_s(\phi, \lambda) $$`
where we assume that we're working on a single model level.

<table class="eqn">
  <tr>
    <td>$$\omega $$</td><td>$$= \frac{\mathrm{D}p}{\mathrm{D}t} = \frac{\partial p}{\partial t} + \mathbf{v}_h \cdot \nabla_{\eta} p + \frac{\mathrm{D}\eta}{\mathrm{D}t} \frac{\partial p}{\partial \eta} $$</td>
  </tr>
  <tr>
    <td></td><td>$$=  0 + \mathbf{v}_h \cdot \nabla_{\eta} p - 0 $$</td>
  </tr>
  <tr>
    <td></td><td>$$=  \frac{u}{a\cos\phi} \frac{\partial}{\partial_{\eta} \lambda}p + 0 \cdot \frac{\partial}{\partial_{\eta} \phi}p  $$</td>
  </tr>
  <tr>
    <td></td><td>$$=  \frac{u}{a\cos\phi} \frac{\partial}{\partial_{\eta} \lambda}p   $$</td>
  </tr>
  <tr>
    <td></td><td>$$=  \frac{u}{a\cos\phi} \frac{\partial}{\partial_{\eta} \lambda} \left(a_k p_0 + b_k p_s(\phi, \lambda) \right)   $$</td>
  </tr>
  <tr>
    <td></td><td>$$=  b_k \frac{u}{a\cos\phi} \frac{\partial}{\partial_{\eta} \lambda} \left(p_s(\phi, \lambda) \right)   $$</td>
  </tr>
</table>


Using the definition `$$$ p_s(\phi, \lambda) = p_0 \exp \left[ -\frac{g}{R_d}\left(\tau_{\textrm{int}, 1}(z_s(\phi, \lambda)) - \tau_{\textrm{int},2}(z_s(\phi, \lambda))I_T(\phi)\right)\right] $$$`
`$$$ \tau_{\mathrm{int},1}(z) = \frac{1}{\Gamma} \left[\exp \left(\frac{\Gamma z}{T_0} \right) - 1 \right] + z \left( \frac{T_0 - T_\mathrm{P}}{T_0T_\mathrm{P}} \right) \exp\left[ -\left(\frac{zg}{bR_dT_0} \right)^2\right]$$$`

`$$$ \tau_{\mathrm{int},2} = \frac{K+2}{2} \left(\frac{T_\mathrm{E} - T_\mathrm{P}}{T_\mathrm{E} T_\mathrm{P}} \right)z\,\exp \left[-\left(\frac{zg}{bR_dT_0} \right)^2 \right] $$$`






