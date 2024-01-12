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

The top boundary is characterized by the quantity `$$ \hat{r}^2 p \phi$$`, if we want to set a 
dirichlet (i.e. point value) boundary condition. This is needed for cancellation of terms in 
an integration-by-parts needed for energy conservation. 

However, there are several problems with this. `$$\phi$$` is a prognostic variable at
the model top in shallow atmosphere homme. We therefore cannot constrain it directly.

The discrete averaging scheme used in HOMME
states that we can extrapolate the model-level quantity `$$p$$` to the model top 
using `$$ p_{i+0.5} `