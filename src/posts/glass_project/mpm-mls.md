---
date: 2021-08-30
tags:
  - posts
  - finite_element
  - glass_blowing
eleventyNavigation:
  parent: Outline of MPM strategy
  key: Rewriting the equations
layout: layouts/post.njk
---

# APIC:

Suppose we have `$$ x_p$$` 
and an evenly-spaced Eulerian grid `$$ x_{i} $$`.
Then associated with each (fixed) particle are a set of interaction weights
`$$ w_p^{i}$$` that describe contribution of the value of a quantity `$$q^n_p$$`
stored at the particle position.
In typical MPM literature this is given by 
`$$$ N(x) = \begin{cases} \frac{1}{2} |x|^3 - x^2 + \frac{2}{3}, & 0 \leq |x| < 1 \\ -\frac{1}{6} |x|^3+ x^2 - 2|x| + \frac{4}{3} & 1 \leq |x| < 2 \\ 0 & \textrm{otherwise}\end{cases}$$$`
and `$$N_i(x) = N(\frac{1}{h} \left(x_1 - ih \right)) N(\frac{1}{h} \left(x_2 - jh \right)) N(\frac{1}{h} \left(x_3 - kh \right))  $$`
which impose 
that points only apply to two neighbor points in each direction

We're chiefly concerned with the particle-to-grid and grid-to-particle transfers given by

`$$$
\begin{align*}
m_i^n &= \sum_p w_{i,p}^nm_p \\
D_p^n &= \sum_i w_{i,p}^n (x_i^n - x_p^n)(x_i^n - x_p^n)^\top\\
m_i^n v_i^n &= \sum_p w_{i,p}^nm_p (v_p^n + B_p^n (D_p^n)^{-1} (x_i^n - x_p^n))
\end{align*}
$$$`
where `$$B_p$$` is transient and stored on particles. G2P reads as
`$$$
\begin{align*}
v_p^{n+1}&= \sum_i w_{i,p}^n v_i^{n+1} \\
B_p^{n+1} &= \sum_i w_{i,p}^n v_i^{n+1} (x_i^n - x_p^n)^\top.
\end{align*}
$$$`
Together these describe a material-agnostic treatment of p2g and g2p transfers. 
In what follows, we make the definition `$$C_p^n = B_p^n (D_p^n)^{-1}$$`.

# MLS reconstruction (before quadrature)
Suppose we have samples `$$ u_i = u(x_i) $$`. 
To better condition the fit, we typically choose a base point `$$x$$` about which
to center our linear fit, which in MPM is typically particle positions.
If we have a (unconstrained) point `$$z$$` at which we want to approximate, 
we can try to reconstruct the value based on `$$P = [p_1(z-x), \ldots, p_n(z-x)]^\top$$`
as `$$ u(z) = P(z-x)^\top c(x) $$`. We choose to minimize `$$ \sum_i \xi_i(x) \left(P(x_i - x)^\top c(x) - u_i \right)$$`
where `$$\xi_i$$` is an interaction kernel with compact support.

Solving this gives `$$u(z) = \xi_i(x) P(z-x) M^{-1}(x)P(x_i - x)u_i $$`
with `$$ M = \sum_i \xi_i(x) P(x_i-x)^\top P(x_i-x)$$`. 
Essentially, the second term in the sum are the weights found by MLS and the 
multiplication by `$$P(z-x)^\top$$` follows from the equation above.

THis motivates the MLS shape functions `$$ \Phi_i(z) = \xi_i(x_p)P(z - x_p)^\top M^{-1}(x_p)P(x_i - x_p)$$`



## Incompressible fixed corotated
Graphics implementations of MPM phrase constitutive relations
in terms of energy functionals. 
The versatile one used in Stomakhin's work 
uses a multiplicative plasticity flow law with `$$ F = F_E F_P$$`.
The calculation of plastic deformation in the solid phase follows 
from [this work](https://math.ucdavis.edu/~jteran/papers/SSCTS13.pdf)
where excess deformation (measured by singular values of `$$F$$`) 
is passed into `$$F_P$$`. In the fluid phase, we set 
`$$ F_E = (J_E)^\frac{1}{d}I$$` at the end of a time step, as deformation
is effectively fully plastic.

The vanilla form of the energy functional is
`$$$ 
\begin{align*}
\Psi_\mu(F_E) &= \mu \|F_E - R_E \|_{F}^2  \\
\Psi_\lambda(\textrm{det}(F_E)) \equiv \Psi_\lambda(J_E)  &= \frac{\lambda}{2}(J_E - 1)^2
\end{align*}
$$$`

This gets modified to be suitable for highly incompressible materials according to
`$$$ \hat{\Psi}(F_E) = \hat{\Psi}_{\mu}(F_E)  + \Psi_\lambda(J_E), \textrm{ where } \hat{\Psi}_\mu(F_E) = \Psi_\mu(J_E^{-1/d} F_E) $$$`
which eliminates any contribution of the dilational component of deformation to `$$ \Psi_\lambda(F_E)$$` 
Using concepts from hyperelasticity (see, e.g., [this classic](https://www.cambridge.org/core/books/nonlinear-continuum-mechanics-for-finite-element-analysis/67AD6DBAAB77E755C09E7FB82565DA0B))
we find `$$ \sigma_\mu = \frac{1}{J}  \pder{\hat{\Psi}_\mu}{F_E}F_E^\top $$`.
This also indicates that an analogue of the Newtonian 
stress-strain relationship is encoded by `$$ \mu $$`.
It's clear we're using the fluid-mechanical decomposition `$$ \sigma = \sigma_\mu + \sigma_\lambda$$`,
so we get by the chain rule 
`$$$ \sigma_\lambda = \frac{1}{J} \left(\pder{\Psi_\lambda}{J_E} \pder{J_E}{F_E} \right)F_E^\top = \frac{1}{J_EJ_P} \pder{\Psi_\lambda}{J_E} J_E F_E^{-\top}F_E^\top = \left(\frac{1}{J_E} \pder{\Psi_\lambda}{J_E}\right) I   \equiv -pI $$$`
Deviatoric stress is dealt with either implicitly or explicitly using the MLS-MPM treatment of
`$$$ \frac{v^* - v^n}{\Delta t} = \frac{1}{\rho_n} \nabla \cdot \sigma_\mu + g $$$`, resulting in gridpoint values of `$$v^*$$`.
In vanilla MPM, quantities needed to solve for pressure are then transfered to cell-centered grid points analogously to mass, e.g.
`$$$ [J_{E}]_c^n = \frac{1}{m_c^n} \sum_p w_{c, p}^n m_p [J_{E}]_p^n.  $$$`
This is the most important equation for determining a MLS-consistent 
particle-to-grid for fluids.

### MLS digression
The continuum momentum equation we're solving looks like 
`$$$ \rho \frac{D v}{Dt} = \nabla \cdot \sigma_\mu + \nabla \cdot \sigma_\lambda + \rho g = \nabla \cdot \sigma_\mu - \nabla p + \rho g $$$`
The weak form of this equation looks like
`$$$\frac{1}{\Delta t} \int_{\Omega^n} \rho (v^*_\alpha - v^n_\alpha) q_{\alpha} \intd{x} = \int_{\partial \Omega^n} T_\alpha  q_\alpha \intd{s} - \int_{\Omega^n} \sigma_{\alpha \beta} \pder{q_\alpha}{x_{\beta}} \intd{x} $$$`

Using the fact that `$$$ \nabla \cdot (\sigma q) = q \cdot (\nabla \cdot \sigma) + \nabla q : \sigma$$$` The derivation looks like 
`$$$
\begin{align*}
  &\rho \der{v}{t} = \nabla \cdot \sigma + \rho g \\
  \implies& \left\langle \rho \der{v}{t}, q \right\rangle = \left\langle\nabla \cdot \sigma, q \right\rangle + \left\langle\rho g, q \right\rangle\\
  \implies& \int_\Omega \left\langle \rho \der{v}{t}, q \right\rangle \intd{x} = \int_\Omega \left\langle\nabla \cdot \sigma, q \right\rangle \intd{x} + \int_{\Omega} \left\langle\rho g, q \right\rangle \intd{x}\\
  \implies& \int_\Omega \left\langle \rho \der{v}{t}, q \right\rangle \intd{x} = \int_\Omega \nabla \cdot (\sigma q)  \intd{x} - \int_\Omega \nabla q : \sigma \intd{x} +  \int_{\Omega} \left\langle\rho g, q \right\rangle \intd{x}\\
  \implies& \int_\Omega \left\langle \rho \der{v}{t}, q \right\rangle \intd{x} = \int_{\partial \Omega \left\langle \sigma q, n \right\rangle \intd{s} - \int_\Omega \nabla q : \sigma \intd{x} +  \int_{\Omega} \left\langle\rho g, q \right\rangle \intd{x}\\
\end{align*}
$$$`
Using the MLS shape functions `$$q_\alpha = P^\top(x-x_p^n) M^{-1}(x_p^n )P(x-x_p^n)  $$`
and using linear polynomials for `$$P$$` (APIC) and tensor-spline weights, we get
`$$$
\begin{align*}
\pder{q_\alpha}{x_\beta} &= \pder{P^\top}{x_\beta}(x-x_p^n) M^{-1}(x_p^n ) P(x_i-x_p^n)   \\
&= M_p^{-1} N_i(x_p^n) (x_{i, \beta} - x_{p, \beta})
\end{align*}
$$$`

### Grid-space pressure correction:


The most economical grid-space equation for this (semi-incompressible) constitutive equation is 
`$$$ 
\begin{align*}
\frac{J_P^n}{\lambda^n J_E^n} \frac{p^{n+1}}{\Delta t} - \delta t \nabla \cdot \left(\frac{1}{\rho_n} \nabla p^{n+1}\right) &= \frac{J_P^n}{\lambda^n J_E^n} \frac{p^n }{\Delta t} - \nabla \cdot v^* \\
&= \frac{J_P^n}{\lambda^n J_E^n} \cdot \left(- \frac{1}{J_P^n} \lambda^n (J_E^n - 1) \right) - \nabla \cdot v^*
\end{align*}
$$$`
which then gives a pressure correction `$$v^{n+1} = v^* + \frac{\Delta t}{\rho^n }\nabla p^{n+1} $$`.



