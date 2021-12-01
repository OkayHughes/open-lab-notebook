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
for stratified flow over a mountain in the absence of friction, described by a streamfunction `$$ \Psi $$`
`$$$ \nabla^2 \Psi  + \frac{\partial_ze}{e} \left[ \partial_z \Psi  - \frac{1}{2}\left\|\nabla \Psi \right\|^2\right] + \frac{N^2}{U^2} \Psi = 0 \qquad \mathscr{E} \textrm{ Nonlinear}$$$`
Where `$$ e = (1/2) \rho_0 U^2$$`, and `$$U = U(z) $$` is the background flow away from the mountain.

We make the following assumptions following Lin: 
- `$$ \Psi $$` has no deflection far upstream of the mountain (i.e. streamlines are horizontal)
- `$$U(z) \equiv C $$` and `$$N(z) \equiv C $$`
- The atmosphere is Boussinesq. 

Under these assumptions, Equation `$$\mathscr{E} $$` Nonlinear becomes
`$$$ \nabla^2 \Psi + \frac{N^2}{U^2} \Psi = 0 \qquad \mathscr{E} \textrm{ Linear}$$$`
which is a linear second order elliptic equation to which we apply the non-linear boundary condition
`$$$ \Psi(x, z) = h(x) \textrm{ at } z = h(x) $$$`
where we are applying the boundary condition at `$$ (x, h(x)) $$` rather than at `$$ (x, 0) $$` in the linear case.

Elementary fourier transform theory [see reference](https://open-lab-notebook-assets.glitch.me/assets/mathematical_references/lin_mesoscale/LinYuhLang_2007_Appendix5_1.pdf) leads us
to calculate `$$\hat{f}(k) = \frac{1}{2\pi}  \int_0$$`
<table class="eqn">
  <tr>
    <td> $$ $$</td> <td>-90 </td> <td>-90 </td> <td>-90 </td> 
  </tr>
  </tr>
</table>