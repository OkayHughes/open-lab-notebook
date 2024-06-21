---
date: 2023-09-01
tags:
  - posts
  - misc
eleventyNavigation:
  parent: Deep Atmosphere HOMME
  key: eta-to-eta initialization
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



In [this article](https://www.ecmwf.int/sites/default/files/elibrary/2011/13179-hydrostatic-and-non-hydrostatic-global-model-ifsarpege-deep-layer-model-formulation-and.pdf)

## Initializing by translating `$$\eta_{\textrm{deep}}$$` to `$$\eta_{\textrm{shallow}}$$`

For simplicity of prototyping I assume that `$$p_{\textrm{top}} = \pi_{\textrm{top}}$$` (eventually this will be `$$p_{\textrm{top}} = \pi_{\textrm{top}}$$`)
and that the initial data allows me to determine `$$ z_{\textrm{top}} $$` based on this pressure value. To initialize the atmosphere,
first calculate 
`$$$ \pi_{\textrm{deep, surf}} = \int_{z_\textrm{surf}}^{z_\textrm{top}} \hat{r}^2 \frac{p}{R_d T} \intd{z} $$$`.
In practice, this integral proceeds from the top of the atmosphere. I do the integral in `$$z$$` coordinates 
but the integrals in Wood and Staniforth provide the analogous integral in `$$\eta_{\textrm{shallow}}$$` coordinates (though height must be determined in any case).
and then use that to calculate `$$\pi_{\textrm{deep}}(\eta_{\cdot,k}) = A(\eta_{\cdot, k}) \pi_0 + B(\eta_{\cdot, k}) \pi_{\textrm{deep, surf}} $$`, for `$$\eta_{\textrm{int}, k}, \eta_{\textrm{model}, k}$$`
Then perform a scan from the top of the atmosphere to get `$$z(\eta_{\cdot, k})$$` that satisfy `$$ \pi_{\textrm{deep}}(\eta_{\cdot,k})  $$`



* The preliminary integral to calculate the total mass in the column cannot be done at the same time as 
* Note that `$$ \pi_{\textrm{deep, surf}} $$` becomes `ps_v` in the code, and may be totally different from the physical pressure at the surface!
