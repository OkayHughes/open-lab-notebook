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
Suppose we have unstructured samples `$$ u_i = u(x_i) $$`. 
