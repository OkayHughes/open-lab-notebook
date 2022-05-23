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

We derive a quadratic approximation to `$$u$$`. 
We use an affine change of variables `$$ \zeta: z \mapsto (z-z_1) $$` 
for notational convenience. We therefore denote `$$\zeta_i = \zeta(z_i) = z_i - z_1$$`
(note, this encodes "signed `$$h$$`s" in some sense).
Our main equation of interest takes
the form 
`$$$f(\zeta) = a_1\zeta^2 + a_2\zeta + a_3 $$$`

with constraints 
<table class="eqn">
  <tr>
    <td>$$ u_1 $$</td><td>$$= a_1\zeta_1^2 + a_2\zeta_1 + a_3 $$ </td>
  </tr>
  <tr>
    <td></td><td>$$\implies a_3 = u_1$$</td>
  </tr>
  <tr>
    <td>$$ u_0 $$</td><td>$$=a_1\zeta_0^2 + a_2\zeta_0 + u_1  $$</td>
  </tr>
  <tr>
    <td>$$ u_2 $$</td><td>$$=a_1\zeta_2^2 + a_2\zeta_2 + u_1 $$</td>
  </tr>
</table>


which we can rewrite as
`$$$
\begin{bmatrix}
\zeta_0^2 & \zeta_0\\
\zeta_2^2 & \zeta_2  
\end{bmatrix}
\begin{bmatrix}
a_1 \\
a_2
\end{bmatrix} =
\begin{bmatrix}
u_2 - u_1\\
u_0 - u_1
\end{bmatrix}
$$$`
asdf

We care about the estimate `$$f'(\zeta_0) = a_2 $$`. 
The solution to the above equations will exist iff `$$z_0 \neq z_1 \neq z_2 $$`. 
We can find said solution analytically
`$$$\begin{bmatrix}
a_1 \\
a_2
\end{bmatrix} =
\frac{1}{\zeta_0^2 \zeta_2 - \zeta_0 \zeta_2^2}
\begin{bmatrix}
  \zeta_2 & -\zeta_0 \\
   -\zeta_2^2 & \zeta_0^2
\end{bmatrix}
\begin{bmatrix}
u_2-u_1\\
u_0 - u_1
\end{bmatrix}$$$`
And so find our second-order approximation of slope to be

<table class="eqn">
  <tr>
    <td>$$a_2$$</td><td>$$= \frac{1}{\zeta_0^2\zeta_2 - \zeta_0\zeta_2^2} \left(-(u_2-u_1)\zeta_2^2 + (u_0-u_1) \zeta_0^2 \right)$$</td>
  </tr>
  <tr>
    <td></td><td>$$= \frac{1}{(z_0-z_1)^2(z_2-z_1) - (z_0-z_1)(z_2-z_1)^2} \left((u_1-u_2)\zeta_2^2 + (u_0-u_1) \zeta_0^2 \right)$$</td>
  </tr>
</table>


