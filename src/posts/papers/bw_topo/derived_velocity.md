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
</table>







