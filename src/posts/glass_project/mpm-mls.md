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
\Psi_\lambda(J_E) = \Psi_\lambda(\textrm{det}(F_E)) = \frac{\lambda}{2}(J_E - 1)^2
\end{align*}
$$$`