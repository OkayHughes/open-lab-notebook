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
  &\hat{r}^2 \partial_s g z = -R_d \frac{p}{\pi} \Theta_v\\
  \implies& \left(\frac{a + \frac{z_0 + z}{2}}{a}\right)^2 (g(z-z_0)) = Q \\
  \implies& \left(\frac{a + \frac{z_0 + z}{2}}{a}\right)^2 (g(z-z_0)) = Q \\
\end{align*}
$$$`