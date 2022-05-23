---
date: 2021-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  key: Potential vorticity in E3SM
  parent: E3SM
layout: layouts/post.njk
---

Define `$$\zeta_\eta = \partial^\eta_x v - \partial^\eta_y u  $$`

<table class="eqn">
  <tr>
  <td>$$\mathrm{PV}$$</td> <td> $$= -g(f \cdot \mathbf{k} + \nabla_\eta \times \mathbf{v}) \cdot \nabla_\eta \theta $$</td>
  </tr>
  <tr>
    <td></td> <td>$$= -\frac{g}{p_0\partial_\eta a + p_s \partial_\eta b } \left[\left((\zeta_\eta + f) \partial_\eta \theta - \left(\partial_\eta v \right) \left(\partial^\eta_x \theta \right) + \left(\partial_\eta u\right) \left( \partial^\eta_y \theta \right) \right) \right]  $$</td>
  </tr>
</table>


In order to compute vertical derivatives, we'll just need to use a finite difference method. 
I'll use a second-order method to start with.

Because we have a vertically lagrangian model, I need to derive an appropriate stencil.
It's always fun when I get to actually use a thing that I learned in a class.

Suppose we have measurements of a quantity `$$u$$` at points `$$z_0, z_1, z_2$$`.
Call these measurements `$$u_0, u_1, u_2$$`.
One could think of these as being ordered along the `$$z$$` axis, but for the sake
of not having to explicitly dealing with boundary conditions I'll try not to actually
use that assumption.

We derive a quadratic approximation to `$$u$$`, and since we only care about
the estimation of the derivative of `$$u$$`