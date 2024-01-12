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
makes a compelling case that our choice of upper boundary condition should retain an essentially isobaric character.
The core takeaway from their paper is that we can use discrete hydrostatic balance to 

