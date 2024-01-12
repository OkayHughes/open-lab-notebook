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
implies that if we know `$$\textrm{dp3d}$$`, `$$\phi $$` ( and thus `$$\hat{r}^2$$`), and `$$ \frac{\partial \phi}{\partial \eta},$$`
then we know non-hydrostatic `$$p$$` at the top model level. Combining this equation of state with the 
discrete averaging, this constrains the value of `$$p$$` at the top interface level. Therefore, 
we actually cannot constrain the boundary values `$$\hat{r}^2 p \phi$$` at the top interface level 
(for example setting `$$ (\hat{r}^2 p \phi)_{\textrm{top}} = C$$`) without forcing `$$p$$` to be a value that 
violates the discrete averaging/extrapolation that is used elsewhere, or by setting the value of `$$\phi$$`
at the model top which is not consistent with the prognostic equation for `$$\phi$$`.

There is another alternative boundary condition that we could try to use. 
`$$$\mu = \frac{\frac{\partial p}{\partial \eta}}{\frac{\partial \pi}{\partial \eta}} \sim \frac{\partial p}{\partial \pi}$$$` measures the 
deviation of physical pressure from hydrostatic balance. The importance
of this term shows up in the prognostic equation for vertical velocity: `$$$ \frac{\partial w}{\partial t} = \frac{1}{\hat{r}}\mathbf{u} \cdot \nabla_\eta w + \dot{\eta} \frac{\partial w}{\partial \eta} - \frac{\|\mathbf{u}\|}{r} - f_c u + g(1-\mu) = 0.$$$`
If `$$\mu \neq 1$$` at the top boundary, then a benign atmosphere in hydrostatic balance with no wind begins to experience vertical acceleration.
In the deep atmosphere we have defined `$$ \mu = \hat{r}^2\frac{\frac{\partial p}{\partial \eta}}{\frac{\partial \pi}{\partial \eta}}$$`
and if we so desire we can set `$$\mu \equiv 1$$` to get `$$ \hat{r}^2\frac{\partial p}{\partial \eta} = \frac{\partial \pi}{\partial \eta} = \textrm{dp3d}.$$`
This gives us a Neumann boundary condition (i.e. a constraint on the vertical derivative) for pressure.
As I just discovered an hour ago, this is the recommended upper boundary condition for the height vertical coordinate
in [Taylor et al, 2020](). However, it turns out that a Neumann boundary condition also runs into the same 
problem as the Dirichlet boundary condition `$$ (\hat{r}^2p \phi)_{\textrm{top}}=C$$`, which is that
the EOS (and the constraint `$$\dot{\eta} = 0$$` on `$$\textrm{dp3d}$$`) combined with discrete averaging 
already determines the values of `$$\phi, p$$`






