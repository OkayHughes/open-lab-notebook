---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: jan 12
layout: layouts/post.njk
---

The top boundary is characterized by the quantity `$$ \hat{r}^2 p \phi$$`, if we want to set a 
dirichlet (i.e. point value) boundary condition. This is needed for cancellation of terms in 
an integration-by-parts needed for energy conservation. 

However, there are several problems with this. `$$\phi$$` is a prognostic variable at
the model top in shallow atmosphere homme. We therefore cannot constrain it directly.

The discrete averaging scheme used in HOMME
states that we can extrapolate the model-level quantity `$$p$$` to the model top 
using `$$ p_{i+1/2} = \frac{(p\Delta \eta)_{i+1} + (p\Delta \eta)_i}{2\Delta \eta_{i+1/2}},$$` `$$p_{1/2} = p_1$$`. 
I don't think this actually agrees with how the calculation of `$$\mu$$` is handled in shallow HOMME.
In shallow HOMME, `$$p_{\textrm{top}} = \pi_{\textrm{top}},$$` which disagrees with this averaging identity.

In any case, the equation of state `$$ \hat{r}^2 \frac{\partial \phi}{\partial \eta} = - R_d \Theta_v \frac{\Pi}{p}$$`
implies t
