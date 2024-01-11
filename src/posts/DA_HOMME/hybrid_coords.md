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
\end{align*}
$$$`
If we don't expand out and use the typical boundary conditions, then
`$$$
  \fder{\mathcal{H}}{\phi} = \partial_{\eta} [\pi] \left(1-\frac{\partial_{\eta}[\hat{r}^2 p]}{\partial_{\eta} [\pi]}\right)
$$$`
and so