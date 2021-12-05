---
date: 2021-08-30
tags:
  - posts
  - climate_451
eleventyNavigation:
  key: Climate 451 Final Project
layout: layouts/post.njk
---

## Purpose

In this project I will examine the (mildly nonlinear) behaviour of flows over complex topography.
Special attention will be paid to the behaviour as steepness of topography increases to infinity.
I'm following the techniques of chapter 5 of [this book](https://search.lib.umich.edu/catalog/record/99187273286006381?query=lin+mesoscale)

## Mathematical prerequisites

We start with the equation from [Long 1953](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.2153-3490.1953.tb01035.x)
for stratified flow over a mountain in the absence of friction, described by a streamfunction perturbation `$$ \delta(x, z) = z - z_0$$`
`$$$ \nabla^2 \delta + \frac{\partial_ze}{e} \left[ \partial_z \delta - \frac{1}{2}\left\|\nabla \delta \right\|^2\right] + \frac{N^2}{U^2} \delta = 0 \qquad \mathscr{E} \textrm{ Nonlinear}$$$`
Where `$$ e = (1/2) \rho_0 U^2$$`, and `$$U = U(z) $$` is the background flow away from the mountain.

We make the following assumptions following Lin:

- `$$ \Psi $$` has no deflection far upstream of the mountain (i.e. streamlines are horizontal)
- `$$U(z) \equiv C $$` and `$$N(z) \equiv C $$`
- The atmosphere is Boussinesq.

Under these assumptions, Equation `$$\mathscr{E} $$` Nonlinear becomes
`$$$ \nabla^2 \delta + \frac{N^2}{U^2} \delta = 0 \qquad \mathscr{E} \textrm{ Linear} $$$`
which is a linear second order elliptic equation to which we apply the non-linear boundary condition
`$$$ \delta(x, z) = h(x) \textrm{ at } z = h(x) \qquad \mathscr{E} \textrm{ BC Nonlinear} $$$`
where we are applying the boundary condition at `$$ (x, h(x)) $$` rather than at `$$ (x, 0) $$` in the linear case.

Elementary fourier transform theory [see reference](https://open-lab-notebook-assets.glitch.me/assets/mathematical_references/lin_mesoscale/LinYuhLang_2007_Appendix5_1.pdf) leads us
to calculate `$$$ \hat{\delta}(k, m) = \frac{1}{2\pi} \int_{-\infty}^\infty \int_{-\infty}^\infty \delta(x, z) e^{-i(kx + mz)} \, \mathrm{d} x \, \mathrm{d} z \qquad \textrm{ with inverse } \qquad \delta(k, m) = 2 \mathrm{Re} \int_{0}^\infty \int_0^ \infty \hat{\delta}(k, m) e^{i(kx + mz)} \, \mathrm{d} k \, \mathrm{d} m $$$`

<table class="eqn">
  <tr>
    <td> $$ 0 = (\nabla^2 \delta + \frac{N^2}{U^2} \delta)(x, z) $$ </td> <td> $$ = (\nabla^2 \delta + l^2 \delta)(x, z) $$ </td>
  </tr>
  <tr>
    <td> </td> <td> $$ = 2 \mathrm{Re} \left[\nabla^2 \left( \int_{0}^\infty \int_0^ \infty  \hat{\delta}(k, m) e^{i(kx + mz)} \, \mathrm{d} k \, \mathrm{d} m \right)\right](x, z) + l^2  \left[\int_{0}^\infty \int_0^ \infty  \hat{\delta}(k, m) e^{i(kx + mz)} \, \mathrm{d} k \, \mathrm{d} m\right](x, z)  $$ </td>
  </tr>
  <tr>
    <td> </td> <td> $$ = 2 \mathrm{Re} \left[ \left( \int_{0}^\infty \int_0^ \infty \nabla^2 \hat{\delta}(k, m) e^{i(kx + mz)} \, \mathrm{d} k \, \mathrm{d} m \right)\right](x, z) + l^2  \left[\int_{0}^\infty \int_0^ \infty  \hat{\delta}(k, m) e^{i(kx + mz)} \, \mathrm{d} k \, \mathrm{d} m\right](x, z)  $$ </td>
  </tr>
  <tr>
    <td> </td> <td> $$ = 2 \mathrm{Re} \int_{0}^\infty \int_0^ \infty  (l^2  - (k^2 + m^2))  \hat{\delta}(k, m) e^{i(kx + mz)} \, \mathrm{d} k \, \mathrm{d} m  $$ </td>
  </tr>
    <tr>
    <td> </td> <td> $$ = \partial_{zz} \hat{\delta}  + (l^2 - k^2) \hat{\delta} $$ </td>
  </tr>
</table>
Ok, I know how to clean this up now.

where we have left the `$$\partial_{zz} $$` term unexpanded because we will use a separable ansatz,
namely `$$ \hat{\delta}(k, z) = \delta(k, 0) e^{-imz} $$` for `$$ l > k $$`, with `$$ m = \sqrt{l^2 - k^2} $$` and `$$ \hat{\delta}(k, z) = \delta(k, 0) e^{-\lambda z} $$` with `$$ \lambda = \sqrt{k^2-l^2}$$`. Note that these
are implementations of the linear boundary conditions. We will implement a newton-raphson method
for the nonlinear boundary conditions later. Under linear boundary conditions we can use FFT to find

`$$$ \delta(x, z) = \mathrm{Re} \left[ \int_0^l \hat{\delta}(k, 0) e^{imz} e^{ikz} \, \mathrm{d} k + \int_l^\infty \hat{\delta}(k, 0) e^{-\lambda z} e^{ikx} \, \mathrm{d} k \right] \qquad \mathscr{E} \textrm{ IFT Linear} $$$`

In order to find the proper nonlinear boundary condition iteratively see [this reference](https://www.researchgate.net/profile/Rene-Laprise/publication/234530395_On_the_Structural_Characteristics_of_Steady_Finite-Amplitude_Mountain_Waves_over_Bell-Shaped_Topography/links/0912f51098946a08d4000000/On-the-Structural-Characteristics-of-Steady-Finite-Amplitude-Mountain-Waves-over-Bell-Shaped-Topography.pdf?origin=publication_detail)


Ok so we have a 3-step pseudocode using a pointwise predictor corrector numerical minimization problem

<table class="eqn">
  <tr>
    <td>Step 0: </td> <td> $$ \delta_1(z=0) $$ </td> <td> $$ = h(x) $$ </td>
  </tr>
  <tr>
    <td>Step 1: </td> <td> $$ E_n(z=h(x)) $$ </td> <td> $$ = \delta_n(z=h(x)) - h(x) $$ </td>
  </tr>
  <tr>
    <td>Step 2: </td> <td> $$ \delta_{n+1}(z=0)$$ </td> <td> $$ = \delta_n(z=0) - E_n(z = h(x_))$$ </td>
  </tr>
</table>

Where each step merely involves a fourier transform. The final solution can be 
extracted by taking a fourier transform along model levels. All that needs
to be passed into the model is the surface coefficients. 



## Todo 12/05/2021

* Test to see that one-step solver works for constant `$$ l $$` and linear lower boundary constraint
* Test that solution resulting from iterative solver actually solves the equation that I 
think I'm solving
* Extend results to use non-constant `$$ l $$` parameters from the [Keller](https://ui.adsabs.harvard.edu/abs/1994JAtS...51.1915K/abstract) paper.
Note: I think the derivation made here is valid under the assumption that `$$ \delta $$` does not
meaningfully contribute to deviations from `$$ \overline{\rho}(z) $$`, and so we can assume that
`$$ \rho_{z=C}(x) $$` is approximately constant.

