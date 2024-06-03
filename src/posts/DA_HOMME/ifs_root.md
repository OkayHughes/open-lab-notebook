---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: Ugh
layout: layouts/post.njk
---

Let `$$\eta_{\textrm{d}}, \eta_{\textrm{s}}$$` be the deep and shallow mass coordinates,
respectively. We define Analytic test cases, as well as, e.g., initializing from data,
specify an invertible map `$$ \eta_{\textrm{s}} \mapsto z$$`. 
When we read `$$\eta$$` values from a file in DA HOMME, these are `$$ \eta_{\textrm{d}}$$` values.
We define the new mass coordinate such that
`$$$
\frac{\partial \pi_\textrm{s}}{\partial \eta_{\textrm{s}}} = \rho g_0 \textrm{ becomes } \frac{\partial \pi_\textrm{d}}{\partial \eta_{\textrm{d}}} = \left(\frac{a+z}{a}\right)^2\rho g_0 = \left(\frac{r}{a}\right)^2 \rho g_0 = \hat{r}^2 \rho g_0
$$$`
and [Wood and Staniforth](https://rmets.onlinelibrary.wiley.com/doi/abs/10.1256/qj.02.153) find that height can be constructed as
`$$$
\begin{align*}
 r^3 = r_s^3 - \frac{3a^2}{g} \int_{\pi'_\textrm{d} = \pi_\textrm{d}}^{\pi'_\textrm{d} = \pi_0} \frac{R_d T}{p} \,\mathrm{d}\pi_\textrm{d}\\
 r^3 = r_s^3 - \frac{3a^2}{g} \int_{\pi'_\textrm{s} = \pi_\textrm{s}}^{\pi'_\textrm{s} = \pi_0} \hat{r}^2 \frac{R_d T}{p} \,\mathrm{d}\pi_\textrm{s}
\end{align*}
$$$`
At the topmost boundary, `$$\pi_\textrm{d} = \pi_{\textrm{s}} = \pi_0$$`, though the integral that
defines how `$$\pi_0$$` is interpreted is different in each model! Since we are using
an isobaric upper boundary condition `$$p = \pi_0$$` at the top boundary in both models, this allows us to determine `$$z(\eta_{\textrm{d, top}}) = z(\eta_{\textrm{s, top}})$$`

Next step: determine ``$$\pi_s$$`` such that above integral gives correct `$$\Delta r$$` over entire atmosphere (ignore discretized `$$\eta$$` for the moment)
Reconstruct `$$\Delta \pi $$` from definition of hybrid coordinate.



In [this article](https://www.ecmwf.int/sites/default/files/elibrary/2011/13179-hydrostatic-and-non-hydrostatic-global-model-ifsarpege-deep-layer-model-formulation-and.pdf)

Define `$$A_F(\eta), B_F(\eta)$$` (where `$$F$$` could stand for something like "file").
We seek modified internal model profiles `$$A_M(\eta), B_M(\eta)$$` that are suitable for small-planet
simulation.

In their parlance `$$\tilde{\pi}$$` is the deep-atmosphere column-integrated mass
and `$$\pi$$` is the shallow-atmosphere column-integrated mass. 



