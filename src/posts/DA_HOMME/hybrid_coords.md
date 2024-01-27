---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Hybrid Coordinates
layout: layouts/post.njk
---

Ok so the code assumes that `$$ A_{\textrm{top}} p_0 + \sum \textrm{dp3d} = p_{sv}  $$`.
Our initialization must satisfy this relation. 

Philosophical interpretation of initialization:
We initialize UMJS14 based on point-wise hydrostatic pressure
at a particular position in the atmosphere. The calculated `dp` variable
that comes out of initialization and is used to call, e.g., `set_elem_state`
is actually `$$dp3d$$` due to how the `$$\eta$$` coordinate behaves in
the deep atmosphere. 


The key to this problem is that
`$$$
\begin{align*}
  &\hat{r}^2 \partial_s g z = -R_d \frac{\Pi}{p} \Theta_v\\
  \implies& \left(\frac{a + \frac{z_0 + z}{2}}{a}\right)^2 (g(z-z_0)) = Q \\
  \implies& \left(1 + \frac{z_0 + z}{2a}\right)^2 (g(z-z_0)) = Q \\
  \implies& g\left(\left(1 + \frac{z_0}{2a}\right) + \frac{z}{2a}\right)^2 (z-z_0) = Q \\
\end{align*}
$$$`
and the derivative is 
`$$$
\begin{align*}
  \partial_z \left[g\left(\left(1 + \frac{z_0}{2a}\right) + \frac{z}{2a}\right)^2 (z-z_0) \right] \approx g\left(\frac{1}{a}(z-z_0)\left(\left(1 + \frac{z_0}{2a}\right) + \frac{z}{2a}\right) + \left(\left(1 + \frac{z_0}{2a}\right) + \frac{z}{2a}\right)^2  \right)
\end{align*}$$$`


## the integration by parts

`$$$
\begin{align*}
    \int \int p\hat{r}^2\delta[\partial_{\eta}[\phi]] + \textrm{BC} +\hat{r}^2 \partial_{\eta} [p] \delta \phi  \intd{\eta} \intd{A} &=  \int  \left[p\hat{r}^2 \phi\right]_{\eta = 1}^{\eta = 0} + \textrm{BC} + \int -\partial_{\eta} [p\hat{r}^2]\delta \phi + \hat{r}^2 \partial_{\eta} [p] \delta \phi  \intd{\eta} \intd{A}\\
    &= \int  \left[p\hat{r}^2 \phi\right]_{\eta = 1}^{\eta = 0} + \textrm{BC} + \int - \hat{r}^2 \partial_{\eta} [p] \delta \phi -p\partial_{\eta} [\hat{r}^2] \delta \phi + \hat{r}^2 \partial_{\eta} [p] \delta \phi  \intd{\eta} \intd{A}\\
    &= \int  \left[p\hat{r}^2 \phi\right]_{\eta = 1}^{\eta = 0} + \textrm{BC} - \int p\partial_{\eta} [\hat{r}^2] \delta \phi \intd{\eta} \intd{A}\\
    &= \int  \left[p\hat{r}^2 \phi\right]_{\eta = 1}^{\eta = 0} + \textrm{BC} - \int p\partial_{\eta} [\hat{r}^2] \delta \phi \intd{\eta} \intd{A}
\end{align*}
$$$`
If we don't expand out and use the typical boundary conditions, then
`$$$
  \fder{\mathcal{H}}{\phi} = \partial_{\eta} [\pi] \left(1-\frac{\partial_{\eta}[\hat{r}^2 p]}{\partial_{\eta} [\pi]}\right)
$$$`


Idea: `$$\mu$$` is used to calculate the vertical pressure gradient force, i.e. `$$\frac{1}{\rho} \nabla p \cdot \mathbf{k} = g\frac{1}{\rho} \frac{\partial_{\eta} p}{\partial_{\eta} \phi} = - g \mu $$`.
In our new, fucked coordinates, the area of the upper surface is larger than the lower surface. 
Therefore in calculating the pressure gradient (and associated quantities), the quantity `$$\mu$$` should take this into account.

Therefore, the choice `$$BC = \hat{r}_{\textrm{top}}^2 p_\textrm{top}\phi_{\textrm{top}}$$` gives
`$$$
\begin{align*}
      \int \int p\hat{r}^2\delta[\partial_{\eta}[\phi]] + \hat{r}^2 p_\textrm{top}\phi_{\textrm{top}} + \partial_{\eta} [\hat{r}^2p] \delta \phi  \intd{\eta} \intd{A} &=  \int  (p\hat{r}^2\delta\phi)_{\textrm{bot}} - (p\hat{r}^2\delta\phi)_{\textrm{top}} + \hat{r}^2 p_\textrm{top}\phi_{\textrm{top}} + \int \partial_{\eta} [\hat{r}^2 p] \delta \phi - \partial_{\eta} [\hat{r}^2p]  \delta \phi  \intd{\eta} \intd{A}
\end{align*}
$$$`
and assuming that we have solved the boundary condition problems at the bottom such that `$$ [\delta \phi]_{\textrm{bot}} = 0$$`, then we get that the boundary condition and integration by parts
perform essentially the same as in the shallow atmosphere case. 
In the new coordinates we must _assume_ that `$$ \mu_{\textrm{top}}=1$$`?


## How to constrain the quantities
The recent paper by the [MPAS folks](https://journals.ametsoc.org/view/journals/mwre/150/8/MWR-D-21-0328.1.xml)
makes a compelling case that our choice of upper boundary condition should retain an essentially isobaric character. IMPORTANT: this publication
concedes conservation of energy near the boundary!
The core takeaway from their paper is that we can use discrete hydrostatic balance to link pressure and height near the top boundary
in a principled way, allowing for hybrids of pressure and height coordinates to be used.

However, we have a bit of a problem. It's immediately obvious that if we set `$$ \hat{r}^2 p\phi = C $$` as our boundary condition, we can either set `$$p$$` or `$$\phi$$`, as `$$\hat{r}$$` is uniquely determined by `$$\phi$$`.
The vertical velocity term prognostic equation takes the form
`$$$
\partial_t [w]  + \frac{\mathbf{u}}{\hat{r}} \cdot \nabla_s w + \dot{s} \partial_{s}[w]  - \frac{\mathbf{u}^2}{r} - f_c [u] + (1-\mu )g = 0
$$$`
it would be _highly_ undesirable if the top boundary initiated motion in
a benign atmosphere (i.e. no wind, vertical hydrostatic balance). In such an atmosphere
the prognostic equations reduce to a constraint `$$ \mu = 1$$`. 
Using the new definition of `$$\mu$$`, this constrains that `$$\partial_{s} \hat{r}^2 p = \partial_{s} \pi$$`.
The pressure is known at the midpoint below the top interface,
and geopotential is prognostic at the upper boundary in pressure coordinates.

The only option for enforcing `$$\mu=1$$` at the top boundary is changing how `$$\textrm{dp3d}$$` is treated 
near the top boundary. As this may wreak havoc on discrete averaging identities, it may actually be prefereable to
allow a mismatch between hydrostatic and nonhydrostatic pressure at the top barrier. Either that or enforce

If we allow such a free surface, then `$$\phi$$` is allowed to evolve according to the prognostic equation.
As such `$$p_{\textrm{top}}$$` is determined to satisfy the boundary condition algebraically. 
However, this may violate the agreement between discrete EOS, which is `$$\hat{r}^2 \partial_{s} \phi = -R_d \Theta_v \frac{\Pi}{p}$$`
and the requirement that midpoints lie halfway between interfaces. 

Can we just change to a Neumann boundary condition at the top?
* Phi at top interface is prognostic
* Combination of discrete averaging and EOS uniquely extrapolates p to top level given phi and pdensity.

Things to note:
  * Sponge layers etc already strongly violate energy conservation at the top boundary!
  * Remapping violates energy conservation on interior of model for lagrangian vertical coordinate!
  * All things considered, math is quite clean and concise on interior of model.
  * Still want to avoid mass loss, as that's sacrosanct.
  * If we allow energy loss at top barrier, then we can just twiddle `$$\Theta_v$$` to accomodate. 

If we allow energy loss at top barrier, then we have a choice of either Neumann or Dirichlet 
boundary conditions at the top. 

## The plan for implementation:
* `$$\mu=1$$` condition determines `$$p$$` at model top given prognostic `$$\phi$$`.
* Slack is taken up by `$$\Theta_v$$`. Unclear if `$$\Theta_v$$` needs to be modified to match definition.


`$$$ 
\begin{align*} 
  &(\hat{r}^2_{top, i} p_{\textrm{top,i}} - \hat{r}^2_{top, m}p_{\textrm{top, m}}) = \frac{\textrm{dp3d}_{top, m}}{2} \\
\end{align*}
$$$`

## Tangent: initializing the atmosphere in general
* Calculate `$$\rho$$` and ensure that `$$z$$` is calculated or read from data.
* Within a column, calculate `$$\int_{\textrm{top}}^{\textrm{bot}} \hat{r}^2 \rho  \intd{z}$$`.
* This can be compared against `$$\sum_i \frac{1}{g} \textrm{dp3d}$$`

