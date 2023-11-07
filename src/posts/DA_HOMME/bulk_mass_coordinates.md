---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Bulk Mass Coordinates
layout: layouts/post.njk
---
These are preliminary notes explaining the difference between what I'm terming "specific-mass coordinates"
and "bulk-mass coordinates". 

The typical hybrid mass coordinate is defined by 
`$$\partial_{\eta} p_h \equiv \partial_{\eta} F_{m} = p_s\partial_{\eta} [A] + p_0 \partial_{\eta} [B] $$` 
where I am going to use `$$F_{m} $$` to refer to a fictitious force that in previous HOMME versions
was called "hydrostatic pressure". 

The well-posedness of this coordinate results from the fact 
`$$\int_{z}^{\textrm{top}} g \rho \intd{z} $$` is monotonically increasing in `$$z$$`. 
Note that the monotonicity holds regardless of whether the atmosphere is in hydrostatic balance. 
However, the form of this equation does indicate two important things about this equation.
Firstly, the use of a notion of "pressure" in the definition of our mass coordinate is largely a 
misnomer. The notion of "hydrostatic pressure" in the non-hydrostatic HOMME model
is misleading and should be abandoned.  Secondly, this equation does allow us to precisely
explain where quantities such as `$$\Delta p$$` which show up in the legacy coordinates we use come from.

We should probably retain legacy `$$\eta$$` model coordinates. 
To my knowledge, they are the best understood way to combine terrain following and pure-mass coordinates
in one concise coordinate system. 

Assume (incorrectly) that the atmosphere is in hydrostatic balance between `$$z_1, z_2$$`. Then
`$$$
\begin{align*}
  \int_{z_1}^{z_2} \rho g \intd{z} = \int_{p_2}^{p_1} \intd{p} = \Delta p
\end{align*}
$$$`
